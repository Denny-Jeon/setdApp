# export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
export VERBOSE=false


# Print the usage message
function printHelp() {
  echo "Usage: "
  echo "  charti.sh <mode>"
  echo "    <mode> - one of 'generate' or 'clean'"
  echo "      - 'generate' - generate required certificates and genesis block"
  echo "      - 'clean  '  - clean certificates and genesis block"
  echo "  charti.sh -h (print this message)"
  echo
}

. ./networkenv.profile

function cleanChannelArtifacts() {
  which configtxgen
  if [ "$?" -ne 0 ]; then
    echo "configtxgen tool not found. exiting"
    exit 1
  fi

  rm -Rf ./channel-artifacts/*

  echo
}

function generateChannelJSON() {
  ordergenesis=$1
  orgmsp=$2

  echo
  echo "#################################################################"
  echo "#######    Generating anchor peer update for ${orgmsp}   ##########"
  echo "#################################################################"
  set -x
  configtxgen -printOrg ${orgmsp} >  ./channel-artifacts/${ordergenesis}/${orgmsp}.json
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for ${orgmsp}..."
    exit 1
  fi
}


function generateAnchor() {
  ordergenesis=$1
  channel=$2
  channelname=$3
  orgmsp=$4

  echo
  echo "#################################################################"
  echo "#######    Generating anchor peer update for ${orgmsp}   ##########"
  echo "#################################################################"
  set -x
  configtxgen -profile ${channel} -outputAnchorPeersUpdate ./channel-artifacts/${ordergenesis}/${orgmsp}anchors.tx -channelID ${channelname} -asOrg ${orgmsp}
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate anchor peer update for ${orgmsp}..."
    exit 1
  fi
}

function generateChannel() {
  ordergenesis=$1
  orderergenesischannel=$2
  channel=$3
  channelname=$4
  org1msp=$5
  org2msp=$6

  echo "##########################################################"
  echo "#########  Generating Orderer Genesis block ##############"
  echo "##########################################################"
  echo "CONSENSUS_TYPE="$CONSENSUS_TYPE
  set -x
  
  if [ -d "channel-artifacts" ]; then
      mkdir ./channel-artifacts
  fi

  mkdir ./channel-artifacts/${ordergenesis}

  configtxgen -profile ${ordergenesis} -channelID ${orderergenesischannel} -outputBlock ./channel-artifacts/${ordergenesis}/genesis.block
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate orderer genesis block..."
    exit 1
  fi
  echo

  echo "#################################################################"
  echo "### Generating channel configuration transaction 'channel.tx' ###"
  echo "#################################################################"
  set -x
  configtxgen -profile ${channel} -outputCreateChannelTx ./channel-artifacts/${ordergenesis}/channel.tx -channelID ${channelname}
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi

  if [ "${org1msp}" == "Org1MSP" ]; then
    generateAnchor ${ordergenesis} ${channel} ${channelname} ${org1msp}
  fi

  if [ "${org2msp}" == "Org2MSP" ]; then
    generateAnchor ${ordergenesis} ${channel} ${channelname} ${org2msp}
    generateChannelJSON  ${ordergenesis} ${org2msp}
  fi
}

function generateChannelArtifacts() {
  which configtxgen
  if [ "$?" -ne 0 ]; then
    echo "configtxgen tool not found. exiting"
    exit 1
  fi

  if [ -d "channel-artifacts/Org1OrdererGenesis" ]; then
    echo "channel-artifacts sub directory exists. exiting"
    echo
    exit 1
  fi

  generateChannel ${ORG1ORDERERGENESIS} ${ORG1ORDERERGENESISCHANNEL_NAME} ${ORG1CHANNEL} ${ORG1CHANNEL_NAME} ${ORG1MSP} ""
  generateChannel ${ORG2ORDERERGENESIS} ${ORG2ORDERERGENESISCHANNEL_NAME} ${ORG2CHANNEL} ${ORG2CHANNEL_NAME} "" ${ORG2MSP}
  generateChannel ${ORG12ORDERERGENESIS} ${ORG12ORDERERGENESISCHANNEL_NAME} ${ORG12CHANNEL} ${ORG12CHANNEL_NAME} ${ORG1MSP} ${ORG2MSP}

  echo
}


# Parse commandline args
if [ "$1" = "-m" ]; then # supports old usage, muscle memory is powerful!
  shift
fi
MODE=$1
shift
# Determine whether starting, stopping, restarting, generating or upgrading
if [ "$MODE" == "generate" ]; then
  EXPMODE="Generating genesis block and channel.tx"
elif [ "$MODE" == "clean" ]; then
  EXPMODE="Clean genesis block and channel.txt"
else
  printHelp
  exit 1
fi

while getopts "h" opt; do
  case "$opt" in
  h | \?)
    printHelp
    exit 0
    ;;
  esac
done


#Create the network using docker compose
if [ "${MODE}" == "generate" ]; then
  generateChannelArtifacts
elif [ "${MODE}" == "clean" ]; then ## Restart the network
  cleanChannelArtifacts
else
  printHelp
  exit 1
fi
