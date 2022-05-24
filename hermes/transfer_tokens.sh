#/bin/bash

set -e

usage() { echo "Usage: $0 <chain> <source_chain_id> <destination_chain_id> <amount> " 1>&2; exit 1; }


if [ "$1" = "" ]
then
  echo "Usage: $0 first arg required, chain config name"
  exit
fi
if [ "$2" = "" ]
then
  echo "No source chain id provided."
  exit
fi
if [ "$3" = "" ]
then
  echo "No destination chain id provided."
  exit
fi
if [ "$4" = "" ]
then
  echo "No channel id provided."
  exit
fi
if [ "$5" = "" ]
then
  echo "No amount provided."
  exit
fi
if [ "$6" = "" ]
then
  echo "No coin denomination provided."
  exit
fi

CHAIN_NAME=$1
SOURCE_CHAIN_ID=$2
DEST_CHAIN_ID=$3
CHANNEL_ID=$4
AMOUNT=$5
CHAIN_DENOM=$6



echo "--------------- INITIATION TRANSFER TOKENS -------------------"

TRANSFER_TOKENS_OUTPUT=$(hermes -c hermes/configs/${CHAIN_NAME}_config.toml tx raw ft-transfer ${DEST_CHAIN_ID} ${SOURCE_CHAIN_ID} transfer ${CHANNEL_ID} ${AMOUNT} -o 1000 -n 1 -d ${CHAIN_DENOM})

echo "--------------- TRANSACTION EXECUTED SUCCESSFULLY -------------------"
echo $TRANSFER_TOKENS_OUTPUT

#07-tendermint-7
#07-tendermint-757
#07-tendermint-7
#07-tendermint-757
#connection-5