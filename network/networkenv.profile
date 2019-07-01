export TARGET_ORG=org1
export CLEAN_MODE=false
export FORCE_MODE=false
export CONSENSUS_TYPE=solo


export ORG1ORDERERGENESIS=Org1OrdererGenesis
export ORG1ORDERERGENESISCHANNEL_NAME=sbnorg1syschannel
export ORG1CHANNEL=Org1Channel
export ORG1CHANNEL_NAME=setchannel1
export ORG1MSP=Org1MSP


export ORG2ORDERERGENESIS=Org2OrdererGenesis
export ORG2ORDERERGENESISCHANNEL_NAME=sbnorg2syschannel
export ORG2CHANNEL=Org2Channel
export ORG2CHANNEL_NAME=setchannel2
export ORG2MSP=Org2MSP


export ORG12ORDERERGENESIS=Org12OrdererGenesis
export ORG12ORDERERGENESISCHANNEL_NAME=sbnorg12syschannel
export ORG12CHANNEL=Org12Channel
export ORG12CHANNEL_NAME=setchannel12


export LANGUAGE=node
export IMAGETAG="latest"
export TIMEOUT=10
export DELAY=3


ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/settle.com/orderers/orderer.settle.com/msp/tlscacerts/tlsca.settle.com-cert.pem
PEER0_ORG1_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.biz1.com/peers/peer0.org1.biz1.com/tls/ca.crt
PEER0_ORG2_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.biz2.com/peers/peer0.org2.biz2.com/tls/ca.crt
CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/setcc/"