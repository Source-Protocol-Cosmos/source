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
  echo "No source chain channel id provided."
  exit
fi
if [ "$5" = "" ]
then
  echo "No destiny chain channel id provided."
  exit
fi
if [ "$6" = "" ]
then
  echo "No amount provided."
  exit
fi
if [ "$7" = "" ]
then
  echo "No coin denomination provided."
  exit
fi

CHAIN_NAME=$1
SOURCE_CHAIN_ID=$2
DEST_CHAIN_ID=$3
SRC_CHANNEL_ID=$4
DEST_CHANNEL_ID=$5
AMOUNT=$6
CHAIN_DENOM=$7



echo "--------------- INITIATION TRANSFER TOKENS -------------------"

TRANSFER_TOKENS_OUTPUT=$(hermes -c hermes/configs/${CHAIN_NAME}_config.toml tx raw ft-transfer ${DEST_CHAIN_ID} ${SOURCE_CHAIN_ID} transfer ${SRC_CHANNEL_ID} ${AMOUNT} -o 1000 -n 1 -d ${CHAIN_DENOM})
#********************************* IMPORTANT ************************************************
#The next two lines are responsible for completing the receive and acknowledge messages between the blockchains involved. 
#These are necessary to complete the transaction. Since this is a task performed by the relayer, 
#they are not mandatory if there is a relayer running at the time of the transfer.
#******************************************************************************************
TRANSFER_TOKENS_RCV=$(hermes -c hermes/configs/${CHAIN_NAME}_config.toml tx raw packet-recv ${DEST_CHAIN_ID} ${SOURCE_CHAIN_ID} transfer ${SRC_CHANNEL_ID})
TRANSFER_TOKENS_ACK=$(hermes -c hermes/configs/${CHAIN_NAME}_config.toml tx raw packet-ack ${SOURCE_CHAIN_ID} ${DEST_CHAIN_ID} transfer ${DEST_CHANNEL_ID})


echo "--------------- TRANSACTION EXECUTED SUCCESSFULLY -------------------"
echo $TRANSFER_TOKENS_OUTPUT
echo $TRANSFER_TOKENS_RCV
echo $TRANSFER_TOKENS_ACK

#07-tendermint-7
#07-tendermint-757
#07-tendermint-7
#07-tendermint-757
#connection-5