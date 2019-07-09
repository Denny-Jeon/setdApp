#!/bin/bash

CRYPTO_CONFIG_KEYSTORE="../../network/crypto-config/peerOrganizations/org1.biz1.com/users/Admin@org1.biz1.com/msp/keystore"
ADMIN_CERTS="../../network/crypto-config/peerOrganizations/org1.biz1.com/users/Admin@org1.biz1.com/msp/admincerts/Admin@org1.biz1.com-cert.pem"
KEY_FILENAME=`ls "${CRYPTO_CONFIG_KEYSTORE}"`
PRIVATE_KEY="${CRYPTO_CONFIG_KEYSTORE}/${KEY_FILENAME}"
HL_COMPOSER_CLI=`which composer`

if [ -f "${PRIVATE_KEY}"  ] && [ -f "${ADMIN_CERTS}" ]; then
    echo ${PRIVATE_KEY}
    echo ${ADMIN_CERTS}

    CARDOUTPUT=PeerAdminOrg1@settle-business-network

    "${HL_COMPOSER_CLI}"  card create -p org1_connection.json -u PeerAdminOrg1 -c "${ADMIN_CERTS}" -k "${PRIVATE_KEY}" -r PeerAdmin -r ChannelAdmin --file $CARDOUTPUT

    "${HL_COMPOSER_CLI}"  card import --file ./PeerAdminOrg1@settle-business-network.card
    "${HL_COMPOSER_CLI}"  card list
    rm ./PeerAdminOrg1@settle-business-network.card

    # if [ "${NOIMPORT}" != "true" ]; then
    #     if "${HL_COMPOSER_CLI}"  card list -c PeerAdmin@hlfv1 > /dev/null; then
    #         "${HL_COMPOSER_CLI}"  card delete -c PeerAdmin@hlfv1
    #     fi

    #     "${HL_COMPOSER_CLI}"  card import --file /tmp/PeerAdmin@hlfv1.card
    #     "${HL_COMPOSER_CLI}"  card list
    #     echo "Hyperledger Composer PeerAdmin card has been imported, host of fabric specified as '${HOST}'"
    #     rm /tmp/PeerAdmin@hlfv1.card
    # else
    #     echo "Hyperledger Composer PeerAdmin card has been created, host of fabric specified as '${HOST}'"
    # fi

fi