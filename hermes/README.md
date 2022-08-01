# Hermes relayer

### Useful links

- https://hermes.informal.systems/index.html
- [Clients](https://hermes.informal.systems/commands/path-setup/clients.html)
- [Connections](https://hermes.informal.systems/commands/path-setup/connections.html)
- [Channels](https://hermes.informal.systems/commands/path-setup/channels.html)

- All of the scripts are meant to be executed from hermes folder.

## Scripts

### Create clients

- For this script you will just need to provide the chain-id.

```
bash ./scripts/create_clients.sh -c cosmos -n theta-testnet-001
```

### Create connection

- Arguments required:
  - Source client
  - Destination chain client

```
bash ./scripts/create_connections.sh -c cosmos -s 07-tendermint-7 -d 07-tendermint-757
```

### Create channels

- Here we just need the connection-id from the sourcechain.

```
bash ./scripts/create_channels.sh -c cosmos -s connection-5
```

### Transfer tokens

- Arguments order required:
  - chain name
  - source chain id
  - destined chain id
  - source channel id
  - destined channel id
  - amount
  - chain denomination

```
bash ./scripts/transfer_token.sh juno sourcechain-testnet uni-3 channel-40 channel-29 1000 ujunox
```

### Create relayer

- Arguments required

  - SOURCE_NETWORK
  - JUNO_NETWORK
  - COSMOS_NETWORK
  - MNEMONIC_FILE
  - CREATE_CLIENTS

  This script is useful to add keys in hermes, create clients, connections and channels automatically.

  The result is saved in [clients/officials.json](clients/officials.json)

```
bash ./scripts/create_relayer.sh -o sourcechain-testnet -d uni-3 -g theta-testnet-001 -c mycosmosaccount -m "./my_mnemonic"
```

### Updater clients

## Docker

Esta aplicacion corre en dos servicios docker

- hermes:
  - run the hermes deamon
  - Optionally you can run [scripts/create_relayer.sh](scripts/create_relayer.sh) to create clients, connections and channels,
- clients-updater
  - This service uses the [clients-updater-cron](./clients-updater-cron) file to create a cron which periodically updates hermes clients using the [updater_clients.sh](scripts/updater_clients.sh) script.

### environment variables

Required for run Docker

You must configure network ids and a mnemonic whose address is funded.
