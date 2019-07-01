# export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
export VERBOSE=false


# Print the usage message
function printHelp() {
  echo "Usage: "
  echo "  cert.sh <mode> [-f] [-o <target-org>]"
  echo "    <mode> - one of 'generate' or 'clean'"
  echo "      - 'generate' - generate required certificates and genesis block"
  echo "      - 'clean  '  - clean certificates and genesis block"
  echo "    -f - force mode, if crypto-config exists, then remove directory and generate"
  echo "    -o <target-org> - generate target-org: org1(default), org2"
  echo "  cert.sh -h (print this message)"
  echo
}

. ./networkenv.profile

function cleanCerts() {
  echo
  echo "##########################################################"
  echo "###############    Clean certificates   ##################"
  echo "##########################################################"
    
  if [ -d "crypto-config" ]; then
    rm -Rf crypto-config
  fi

  rm -f docker-compose-org1.yaml docker-compose-org2.yaml

  echo
}


function generateCerts() {
  which cryptogen
  if [ "$?" -ne 0 ]; then
    echo "cryptogen tool not found. exiting"
    exit 1
  fi
  echo
  echo "##########################################################"
  echo "##### Generate certificates using cryptogen tool #########"
  echo "##########################################################"

  if [ "$FORCE_MODE" == "true" ]; then
    rm -Rf crypto-config
  fi

  if [ -d "crypto-config" ]; then
    if [ -d "crypto-config/peerOrganizations" ]; then
        EXIST_ORG=`(ls crypto-config/peerOrganizations | grep "${TARGET_ORG}.")`
        if [ "$EXIST_ORG" == "" ]; then
            echo "not exist org ${TARGET_ORG}"
            echo
        else
            echo "cypto-config directory exists. exiting"
            echo
            exit 1
        fi
    fi
  fi
  

  set -x
  cryptogen generate --config=./${TARGET_ORG}/crypto-config.yaml
  res=$?
  set +x
  if [ $res -ne 0 ]; then
    echo "Failed to generate certificates..."
    exit 1
  fi
  echo
}



function replacePrivateKey() {
  # sed on MacOSX does not support -i flag with a null extension. We will use
  # 't' for our back-up's extension and delete it at the end of the function
  ARCH=$(uname -s | grep Darwin)
  if [ "$ARCH" == "Darwin" ]; then
    OPTS="-it"
  else
    OPTS="-i"
  fi

  # Copy the template to the file that will be modified to add the private key
  cp docker-compose-${TARGET_ORG}-template.yaml docker-compose-${TARGET_ORG}.yaml

  # The next steps will replace the template's contents with the
  # actual values of the private key file names for the two CAs.
  CURRENT_DIR=$PWD
  cd crypto-config/peerOrganizations/${TARGET_ORG}.*/ca/
  PRIV_KEY=$(ls *_sk)
  cd "$CURRENT_DIR"
  sed $OPTS "s/CA_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose-${TARGET_ORG}.yaml
}



# Parse commandline args
if [ "$1" = "-m" ]; then # supports old usage, muscle memory is powerful!
  shift
fi
MODE=$1
shift
# Determine whether starting, stopping, restarting, generating or upgrading
if [ "$MODE" == "generate" ]; then
  EXPMODE="Generating cert"
elif [ "$MODE" == "clean" ]; then
  EXPMODE="Clean certs"
else
  printHelp
  exit 1
fi

while getopts "h?c:t:d:f:s:l:i:o:v" opt; do
  case "$opt" in
  h | \?)
    printHelp
    exit 0
    ;;
  f)
    FORCE_MODE=true
    ;;
  o)
    TARGET_ORG=$OPTARG
    ;;
  esac
done


#Create the network using docker compose
if [ "${MODE}" == "generate" ]; then
  generateCerts
  replacePrivateKey
elif [ "${MODE}" == "clean" ]; then ## Restart the network
  cleanCerts
else
  printHelp
  exit 1
fi