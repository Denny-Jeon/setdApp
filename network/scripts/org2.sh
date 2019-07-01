#!/bin/bash

echo " ____    _____      _      ____    _____ "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"
echo "\___ \    | |     / _ \   | |_) |   | |  "
echo " ___) |   | |    / ___ \  |  _ <    | |  "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "
echo
echo "Settlement Businness Network (SBN) end-to-end test"
echo


# export FABRIC_CFG_PATH=${PWD}
# export VERBOSE=false

# . ./scripts/networkenv.profile

CHANEL_DIR="Org1OrdererGenesis"
CHANEL2_DIR="Org2OrdererGenesis"
CHANNEL_NAME="$1"
DELAY="$2"
LANGUAGE="$3"
TIMEOUT="$4"
VERBOSE="$5"
: ${CHANNEL_NAME:="setchannel1"}
: ${DELAY:="5"}
: ${LANGUAGE:="node"}
: ${TIMEOUT:="15"}
: ${VERBOSE:="false"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=10
VERSION=1.0

echo "Channel name : "$CHANNEL_NAME


ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/settle.com/orderers/orderer.settle.com/msp/tlscacerts/tlsca.settle.com-cert.pem
PEER0_ORG1_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.biz1.com/peers/peer0.org1.biz1.com/tls/ca.crt
PEER0_ORG2_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.biz2.com/peers/peer0.org2.biz2.com/tls/ca.crt
# 주의 반드시 디렉토리의 끝은 / 로 끝나야 할 것
CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/setcc/node/"


setGlobals() {
  PEER=$1
  ORG=$2

  if [ $ORG -eq 1 ]; then
    CORE_PEER_LOCALMSPID="Org1MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.biz1.com/users/Admin@org1.biz1.com/msp
    if [ $PEER -eq 0 ]; then
      CORE_PEER_ADDRESS=peer0.org1.biz1.com:7051
    else
      CORE_PEER_ADDRESS=peer1.org1.biz1.com:8051
    fi
  elif [ $ORG -eq 2 ]; then
    CORE_PEER_LOCALMSPID="Org2MSP"
    CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.biz2.com/users/Admin@org2.biz2.com/msp
    if [ $PEER -eq 0 ]; then
      CORE_PEER_ADDRESS=peer0.org2.biz2.com:9051
    else
      CORE_PEER_ADDRESS=peer1.org2.biz2.com:10051
    fi
  else
    echo "================== ERROR !!! ORG Unknown =================="
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}


## Sometimes Join takes time hence RETRY at least 5 times
joinChannelWithRetry() {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG


  env | grep CORE

  
  set -x
  peer channel join -b $CHANNEL_NAME.block >&log.txt
  res=$?
  set +x
  cat log.txt
  if [ $res -ne 0 -a $COUNTER -lt $MAX_RETRY ]; then
    COUNTER=$(expr $COUNTER + 1)
    echo "peer${PEER}.org${ORG} failed to join the channel, Retry after $DELAY seconds"
    sleep $DELAY
    joinChannelWithRetry $PEER $ORG
  else
    COUNTER=1
  fi
  verifyResult $res "After $MAX_RETRY attempts, peer${PEER}.org${ORG} has failed to join channel '$CHANNEL_NAME' "
}


# verify the result of the end-to-end test
verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo "========= ERROR !!! FAILED to execute End-2-End Scenario ==========="
    echo
    exit 1
  fi
}


updateAnchorPeers() {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG

  set -x
  peer channel update -o orderer.settle.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CHANEL_DIR}/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
  res=$?
  set +x
  
  cat log.txt
  verifyResult $res "Anchor peer update failed"
  echo "===================== Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL_NAME' ===================== "
  sleep $DELAY
  echo
}


installChaincode() {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG
  VERSION=${3:-1.0}
  set -x

  env
  
  peer chaincode install -n setcc -v ${VERSION} -l ${LANGUAGE} -p ${CC_SRC_PATH} >&log.txt

  res=$?
  set +x
  cat log.txt
  verifyResult $res "Chaincode installation on peer${PEER}.org${ORG} has failed"
  echo "===================== Chaincode is installed on peer${PEER}.org${ORG} ===================== "
  echo
}


instantiateChaincode() {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG
  VERSION=${3:-1.0}

  set -x
  peer chaincode instantiate -o orderer.settle.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n setcc -l ${LANGUAGE} -v ${VERSION} -c '{"Args":["initLedger"]}' -P "AND ('Org1MSP.peer')" >&log.txt
  res=$?
  set +x

  cat log.txt
  verifyResult $res "Chaincode instantiation on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME' failed"
  echo "===================== Chaincode is instantiated on peer${PEER}.org${ORG} on channel '$CHANNEL_NAME' ===================== "
  echo
}


createChannel() {
	setGlobals 0 1

  env

	set -x
	peer channel create -o orderer.settle.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CHANEL_DIR}/channel.tx --tls $CORE_PEER_TLS_ENABLED  --cafile $ORDERER_CA >&log.txt
	res=$?
	set +x
	cat log.txt
	
    verifyResult $res "Channel creation failed"
	echo "===================== Channel '$CHANNEL_NAME' created ===================== "
	echo
}

joinChannel () {
	# for org in 1 2; do
	for org in 1; do
	    for peer in 0 1; do
        joinChannelWithRetry $peer $org
        echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME' ===================== "
        sleep $DELAY
        echo
	    done
	done
}


setOrdererGlobals() {
  CORE_PEER_LOCALMSPID="OrdererMSP"
  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/settle.com/orderers/orderer.settle.com/msp/tlscacerts/tlsca.settle.com-cert.pem
  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/settle.com/users/Admin@settle.com/msp
}



fetchChannelConfig() {
  CHANNEL=$1
  OUTPUT=$2

  setOrdererGlobals

  echo "Fetching the most recent configuration block for the channel"
  set -x
  peer channel fetch config config_block.pb -o orderer.settle.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
  set +x

  echo "Decoding config block to JSON and isolating config to ${OUTPUT}"
  set -x
  configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config >"${OUTPUT}"
  set +x
}


createConfigUpdate() {
  CHANNEL=$1
  ORIGINAL=$2
  MODIFIED=$3
  OUTPUT=$4

  set -x
  configtxlator proto_encode --input "${ORIGINAL}" --type common.Config >original_config.pb
  configtxlator proto_encode --input "${MODIFIED}" --type common.Config >modified_config.pb
  configtxlator compute_update --channel_id "${CHANNEL}" --original original_config.pb --updated modified_config.pb >config_update.pb
  configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate >config_update.json
  echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . >config_update_in_envelope.json
  configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope >"${OUTPUT}"
  set +x
}


signConfigtxAsPeerOrg() {
  PEERORG=$1
  TX=$2
  setGlobals 0 $PEERORG
  set -x
  peer channel signconfigtx -f "${TX}"
  set +x
}


echo "Fetching channel config block from orderer..."
env | grep CORE
set -x
echo $ORDERER_CA
peer channel fetch 0 $CHANNEL_NAME.block -o orderer.settle.com:7050 -c $CHANNEL_NAME --tls  --cafile $ORDERER_CA >&log.txt
res=$?
set +x
cat log.txt
verifyResult $res "Fetching config block from orderer has Failed"

joinChannelWithRetry 0 2
echo "===================== peer0.org2 joined channel '$CHANNEL_NAME' ===================== "
joinChannelWithRetry 1 2
echo "===================== peer1.org2 joined channel '$CHANNEL_NAME' ===================== "

echo "Installing chaincode 2.0 on peer0.org2..."
installChaincode 0 2 2.0

# instantiateChaincode 0 2 2.0

echo
echo "========= Org2 is now halfway onto your first network ========= "
echo


exit 0