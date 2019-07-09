# export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
export VERBOSE=false


# Print the usage message
function printHelp() {
  echo "Usage: "
  echo "  network.sh <mode> [-o <target-org>]"
  echo "    <mode> - one of 'generate' or 'clean'"
  echo "      - 'start' - start hyperledger network (default docker-compose-org1.yaml, docker-compose-org1-couch.yaml)"
  echo "      - 'stop  '  - clean certificates and genesis block"
  echo "      - 'down  '  - clean certificates and genesis block"  
  echo "    -o <target-org> - generate target-org: org1(default), org2"
  echo "    -v <version> - chaincode version"
  echo "  network.sh -h (print this message)"
  echo
}

. ./networkenv.profile


# Parse commandline args
if [ "$1" = "-m" ]; then # supports old usage, muscle memory is powerful!
  shift
fi
MODE=$1
shift
# Determine whether starting, stopping, restarting, generating or upgrading
if [ "$MODE" == "start" ]; then
  EXPMODE="Starting docker "
elif [ "$MODE" == "stop" ]; then
  EXPMODE="Stoping docker"
elif [ "$MODE" == "down" ]; then
  EXPMODE="Down docker"
elif [ "$MODE" == "startsbn" ]; then
  EXPMODE="Create, join channel and then install, initiate chaincode peer0.org1.biz1.com"
elif [ "$MODE" == "extendsbn" ]; then
  EXPMODE="Extend org1 and org2 and then upgrade chaincode peer0.org1.biz1.com, peer1.org2.biz2.com"
elif [ "$MODE" == "upgradesbn" ]; then
  EXPMODE="Upgrade chaincode"
else
  printHelp
  exit 1
fi


while getopts "h?o:f" opt; do
  case "$opt" in
  h | \?)
    printHelp
    exit 0
    ;;
  o)
    TARGET_ORG=$OPTARG
    ;;
  v)
    CC_VERSION=$OPTARG
    ;;
  esac
done

networkUp() {
  if [ ! -d "crypto-config" ]; then
      echo "ERROR! First generate crypto-config. please execute certngenesis.sh"
      exit 1
  fi

  echo $TARGET_ORG

  #Create the network using docker compose
  COMPOSE_FILE=docker-compose-${TARGET_ORG}.yaml
  COMPOSE_FILE_COUCH=docker-compose-${TARGET_ORG}-couch.yaml

  IMAGE_TAG=$IMAGETAG docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_COUCH up -d 2>&1
  docker ps -a
}


networkStop() {
  #Create the network using docker compose
  COMPOSE_FILE=docker-compose-${TARGET_ORG}.yaml
  COMPOSE_FILE_COUCH=docker-compose-${TARGET_ORG}-couch.yaml

  docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_COUCH down --volumes --remove-orphans
  docker ps -a
}


function clearContainers() {
  CONTAINER_IDS=$(docker ps -a | awk '($2 ~ /dev-peer*/) {print $1}')
  if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" == " " ]; then
    echo "---- No containers available for deletion ----"
  else
    docker rm -f $CONTAINER_IDS
  fi
}

function removeUnwantedImages() {
  DOCKER_IMAGE_IDS=$(docker images | awk '($1 ~ /dev-peer*/) {print $3}')
  if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" == " " ]; then
    echo "---- No images available for deletion ----"
  else
    docker rmi -f $DOCKER_IMAGE_IDS
  fi
}


networkDown() {
  #Create the network using docker compose
  COMPOSE_FILE=docker-compose-org1.yaml
  COMPOSE_FILE_COUCH=docker-compose-org1-couch.yaml

  COMPOSE_FILE2=docker-compose-org2.yaml
  COMPOSE_FILE_COUCH2=docker-compose-org2-couch.yaml

  docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_COUCH -f $COMPOSE_FILE2 -f $COMPOSE_FILE_COUCH2 down --volumes --remove-orphans
  docker ps -a

  #Cleanup the chaincode containers
  clearContainers
  #Cleanup images
  removeUnwantedImages
  # remove orderer block and other channel configuration transactions and certs
  rm -rf channel-artifacts/* crypto-config
  # remove the docker-compose yaml file that was customized to the example
  rm -f docker-compose-org1.yaml docker-compose-org2.yaml
}


sbnUp() {
  docker exec cli scripts/org1.sh
}


sbnExtend() {
  docker exec cli scripts/org1-fetchChannelConfigUpdateSignPeerOrg.sh

  #Create the network using docker compose
  COMPOSE_FILE=docker-compose-org2.yaml
  COMPOSE_FILE_COUCH=docker-compose-org2-couch.yaml

  IMAGE_TAG=$IMAGETAG docker-compose -f $COMPOSE_FILE -f $COMPOSE_FILE_COUCH up -d 2>&1
  docker ps -a

  docker exec Org2cli scripts/org2.sh

  docker exec cli scripts/org1-chaincodeupgrade.sh

  # docker exec Org2cli scripts/org2-chaincodestart.sh
}


sbnUpgrade() {
  echo
}


#Create the network using docker compose
if [ "${MODE}" == "start" ]; then
  networkUp
elif [ "${MODE}" == "stop" ]; then ## Restart the network
  networkStop
elif [ "${MODE}" == "down" ]; then ## Restart the network
  networkDown
elif [ "${MODE}" == "startsbn" ]; then ## Restart the network
  sbnUp
elif [ "${MODE}" == "extendsbn" ]; then ## Restart the network
  sbnExtend
else
  printHelp
  exit 1
fi

