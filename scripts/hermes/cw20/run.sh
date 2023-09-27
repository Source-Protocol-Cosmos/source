#!/bin/bash

source ./scripts/hermes/cw20/helpers.sh

SOURCED_NODE='http://localhost:26657/'
SOURCED_NODE2='http://localhost:36657/' # receiving chain
# globalfee will break this in the future
export KEY_ADDR="source1hj5fveer5cjtn4wd6wstzugjfdxzl0xps73ftl"

TX_FLAGS="--gas-prices="0.03usource" --gas 5000000 -y -b block --node http://localhost:26657 --output json --keyring-backend test --chain-id local-1"
export SOURCED_COMMAND_ARGS="$TX_FLAGS --from source1"

TX_FLAGS2="--gas-prices="0.03usource" --gas 5000000 -y -b block --node $SOURCED_NODE2 --output json --keyring-backend test --chain-id local-2"
export SOURCED_COMMAND_ARGS2="$TX_FLAGS2 --from source1"


BINARY=sourced

function upload_cw20 {
    TYPE="CW20 Token"

    echo "Storing $TYPE contract..."
    TX=$(sourced tx wasm store ./scripts/hermes/cw20/cw20_base.wasm $SOURCED_COMMAND_ARGS | jq -r '.txhash') && echo "$TX"
    CW_CODE_ID=$(sourced q tx $TX --output json --node http://localhost:26657 | jq -r '.logs[0].events[] | select(.type == "store_code").attributes[] | select(.key == "code_id").value') && echo "Code Id: $CW_CODE_ID"
    
    echo "Instantiating $TYPE contract..."
    INIT_JSON=`printf '{"name":"reece","symbol":"pbcup","decimals":6,"initial_balances":[{"address":"%s","amount":"10000"}]}' $KEY_ADDR`
    TX_UPLOAD=$(sourced tx wasm instantiate "$CW_CODE_ID" $INIT_JSON --label "e2e-$TYPE" $SOURCED_COMMAND_ARGS --admin $KEY_ADDR | jq -r '.txhash') && echo $TX_UPLOAD
    export CW20_CONTRACT=$(sourced query tx $TX_UPLOAD --output json | jq -r '.logs[0].events[0].attributes[0].value') && echo "CW20_CONTRACT: $CW20_CONTRACT"        
}

# This only allows the above CW20_CONTRACT token to be sent. Can add more if you want with the execute "allow" JSON
# {"allow":{"contract":"your_cw20_conrtact_addr"}}
function upload_cw20_ics20 {
    TYPE="CW20-ICS20"

    echo "Storing $TYPE contract..."
    TX=$(sourced tx wasm store ./scripts/hermes/cw20/cw20_ics20.wasm $SOURCED_COMMAND_ARGS | jq -r '.txhash') && echo "$TX"
    CW_CODE_ID=$(sourced q tx $TX --output json --node http://localhost:26657 | jq -r '.logs[0].events[] | select(.type == "store_code").attributes[] | select(.key == "code_id").value') && echo "Code Id: $CW_CODE_ID"
    
    echo "Instantiating $TYPE contract..."
    # INIT_JSON=`printf '{"name":"reece","symbol":"pbcup","decimals":6,"initial_balances":[{"address":"%s","amount":"10000"}]}' $KEY_ADDR`
    INIT_JSON=`printf '{"default_timeout":10000,"gov_contract":"%s","allowlist":[{"contract":"%s","gas_limit":500000}]}' $KEY_ADDR $CW20_CONTRACT`    
    TX_UPLOAD=$(sourced tx wasm instantiate "$CW_CODE_ID" $INIT_JSON --label "e2e-$TYPE" $SOURCED_COMMAND_ARGS --admin $KEY_ADDR | jq -r '.txhash') && echo $TX_UPLOAD
    export ICS20_CONTRACT=$(sourced query tx $TX_UPLOAD --output json | jq -r '.logs[0].events[0].attributes[0].value') && echo "ICS20_CONTRACT: $ICS20_CONTRACT"          
}


upload_cw20 # $CW20_CONTRACT
upload_cw20_ics20 # $ICS20_CONTRACT

echo -e "\n\n"
echo "CW20_CONTRACT=$CW20_CONTRACT"
echo "ICS20_CONTRACT=$ICS20_CONTRACT"
echo -e "\n"

read -p "Press enter to continue after you start the relayer with the above contract address..."

# send 10 token via ibc transfer

# We send to the same account on the 2nd chain
TRANSFER_MSG=`printf '{"channel":"channel-0","remote_address":"source1efd63aw40lxf3n4mhf7dzhjkr453axurv2zdzk","timeout":100}' | base64 -w 0`
MSG=`printf '{"send":{"contract":"%s","amount":"10","msg":"%s"}}' $ICS20_CONTRACT $TRANSFER_MSG`
# send the Tx
sourced tx wasm execute $CW20_CONTRACT $MSG --gas-prices="0.03usource" --gas 5000000 -y -b block --node http://localhost:26657 --output json --keyring-backend test --chain-id local-1 --from source1

sleep 6

sourced query wasm contract-state smart "$CW20_CONTRACT" '{"balance":{"address":"source1hj5fveer5cjtn4wd6wstzugjfdxzl0xps73ftl"}}' --output json --node http://localhost:26657

sourced q ibc-transfer denom-traces --node http://localhost:36657


# Has a new IBC token denom which is the transfered one
sourced q bank balances source1efd63aw40lxf3n4mhf7dzhjkr453axurv2zdzk --node http://localhost:36657