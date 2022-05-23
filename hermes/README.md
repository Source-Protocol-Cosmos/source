# Hermes relayer scripts

* For all scripts you will need to provide the name of the blockchain config you would like to make an operation with (apart from the source-chain network). The available options are all in the configs folder.

* All of the scripts are meant to be executed from root folder.

### Create clients

* For this script you will just need to provide the chain-id.

```
bash hermes/create_clients.sh -c cosmos -n theta-testnet-001
```

### Create connection

* Arguments required: 
    * Source client
    * Destination chain client

```
bash hermes/create_connections.sh -c cosmos -s 07-tendermint-7 -d 07-tendermint-757
```

### Create channels

* Here we just need the connection-id from the sourcechain.

```
bash hermes/create_channels.sh -c cosmos -s connection-5
```

### Transfer tokens
