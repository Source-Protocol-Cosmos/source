# https://github.com/osmosis-labs/osmosis/blob/main/tests/ibc-hooks/test_hooks.sh

CHAIN_A_ARGS="--keyring-backend test --chain-id local-1 --home $HOME/.source1/ --node http://localhost:26657 --gas 5000000 -b block --yes --fees=12500usource"
CHAIN_B_ARGS="--keyring-backend test --chain-id local-2 --home $HOME/.source2/ --node http://localhost:36657 --gas 5000000 -b block --yes --fees=12500usource"

# upload contract on chain B (receiving chain)
sourced tx wasm store ./scripts/ibcmemo/counter.wasm --from source1 $CHAIN_B_ARGS
CONTRACT_ID=$(sourced query wasm list-code --node http://localhost:36657 -o json | jq -r '.code_infos[-1].code_id')
echo "contract id: $CONTRACT_ID"

sourced tx wasm instantiate "$CONTRACT_ID" '{"count":0}' --from source1 --no-admin --label=counter $CHAIN_B_ARGS 
export CONTRACT_ADDRESS=$(sourced query wasm list-contract-by-code 1 --node http://localhost:36657 -o json | jq -r '.contracts | [last][0]')
echo "contract address: $CONTRACT_ADDRESS" # no balance, new contract

# Send a memo with the wasm message to execute on Chain B from chain A 
MEMO=$(jenv -c '{"wasm":{"contract":$CONTRACT_ADDRESS,"msg": {"increment": {}} }}' )
sourced tx ibc-transfer transfer transfer channel-0 $CONTRACT_ADDRESS 1usource --from source1 $CHAIN_A_ARGS --memo "$MEMO" --packet-timeout-height 0-0

# Wait for relay
sleep 6

# Ensure the balance has gone up and both are NOT null
denom=$(sourced query bank balances "$CONTRACT_ADDRESS" --node http://localhost:36657 -o json | jq -r '.balances[0].denom')
balance=$(sourced query bank balances "$CONTRACT_ADDRESS" --node http://localhost:36657 -o json | jq -r '.balances[0].amount')
echo "denom: $denom"
echo "balance: $balance"

export ADDR_IN_CHAIN_A=$(sourced q ibchooks wasm-sender channel-0 "source1hj5fveer5cjtn4wd6wstzugjfdxzl0xps73ftl" --node http://localhost:26657)

# Total Funds
QUERY=$(jenv -c -r '{"get_total_funds": {"addr": $ADDR_IN_CHAIN_A}}')
sourced query wasm contract-state smart "$CONTRACT_ADDRESS" "$QUERY" --node http://localhost:36657 -o json

# Count
QUERY=$(jenv -c -r '{"get_count": {"addr": $ADDR_IN_CHAIN_A}}')
sourced query wasm contract-state smart "$CONTRACT_ADDRESS" "$QUERY" --node http://localhost:36657 -o json
