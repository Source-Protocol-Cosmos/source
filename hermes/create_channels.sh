#/bin/bash

set -e

usage() { echo "Usage: $0 [-c chain] [-s channel_source_id]" 1>&2; exit 1; }

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
          CONNECTION_SOURCE_ID=${OPTARG}
          ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${CHAIN_NAME}" ] || [ -z "${CONNECTION_SOURCE_ID}" ]; then
    usage
fi

echo "--------------- CREATING HERMES CHANNEL -------------------"

CHANNEL_OUTPUT=$(hermes -c hermes/configs/${CHAIN_NAME}_config.toml create channel --port-a transfer --port-b transfer -o unordered sourcechain-testnet ${CONNECTION_SOURCE_ID})

echo "--------------- CHANNEL CREATED SUCCESSFULLY -------------------"
echo $CHANNEL_OUTPUT