#/bin/bash

set -e

usage() { echo "Usage: $0 [-c <chain>] [-n <network_name>]" 1>&2; exit 1; }

while getopts ":c:n:" o; do
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
        n)
          NETWORK_NAME=${OPTARG}
          ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${CHAIN_NAME}" ] || [ -z "${NETWORK_NAME}" ]; then
    usage
fi

echo "--------------- CREATING HERMES CLIENTS -------------------"

echo "CREATING CLIENT DEST_CHAIN: SOURCE SOURCE_CHAIN:${CHAIN_NAME}"

CLIENT_ONE_OUTPUT=$(hermes -c hermes/${CHAIN_NAME}_config.toml tx raw create-client sourcechain-testnet $NETWORK_NAME) 

echo "CREATING SECOND CLIENT DEST_CHAIN: ${CHAIN_NAME} SOURCE_CHAIN: SOURCE"

CLIENT_TWO_OUTPUT=$(hermes -c hermes/${CHAIN_NAME}_config.toml tx raw create-client $NETWORK_NAME sourcechain-testnet) 

echo "--------------- CLIENTS CREATED SUCCESSFULLY -------------------"
echo $CLIENT_ONE_OUTPUT
echo $CLIENT_TWO_OUTPUT
