#/bin/bash

set -e

usage() { echo "Usage: $0 [-c <chain>] [-s <client_source_chain_id>] [-d <client_second_chain_id>]" 1>&2; exit 1; }

while getopts ":c:s:d:" o; do
    case "${o}" in
        c)
            c=${OPTARG}
             ((c == "juno" || c == "osmosis" || c == "cosmos" )) || usage
            case $c in
                juno)
                    CHAIN_NAME=$c
                    ;;
                osmosis)      
                    CHAIN_NAME=$c
                    ;;
                cosmos)      
                    CHAIN_NAME=$c
                    ;;
                *)
                    usage
                    ;;
            esac
            ;;
        s)
          CLIENT_ONE_ID=${OPTARG}
          ;;
        d)
          CLIENT_TWO_ID=${OPTARG}
          ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${CHAIN_NAME}" ] || [ -z "${CLIENT_ONE_ID}" ] || [ -z "${CLIENT_TWO_ID}" ]; then
    usage
fi

echo "--------------- CREATING HERMES CONNECTION -------------------"

CONNECTION_OUTPUT=$(hermes -c hermes/configs/${CHAIN_NAME}_config.toml create connection --client-a ${CLIENT_ONE_ID} --client-b ${CLIENT_TWO_ID} sourcechain-testnet)

echo "--------------- CONNECTION CREATED SUCCESSFULLY -------------------"
echo $CONNECTION_OUTPUT

#07-tendermint-7
#07-tendermint-757