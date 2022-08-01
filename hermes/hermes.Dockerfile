FROM rust:1.31
WORKDIR /hermes

# Download hermes binary
RUN wget -c https://github.com/informalsystems/ibc-rs/releases/download/v1.0.0-rc.0/hermes-v1.0.0-rc.0-aarch64-unknown-linux-gnu.tar.gz
RUN mkdir -p /root/.hermes/bin
RUN tar -C /root/.hermes/bin/ -vxzf hermes-v1.0.0-rc.0-aarch64-unknown-linux-gnu.tar.gz
RUN rm hermes-v1.0.0-rc.0-aarch64-unknown-linux-gnu.tar.gz

# Add hermes to path
ENV PATH="/root/.hermes/bin:$PATH"

# node
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN apt update && apt install -y --no-install-recommends nodejs

# Execute createRelayer.js and run hermes
CMD npm install && node ./scripts/createRelayer.js --configPath $CONFIG_PATH --mnemonicPath $MNEMONIC_PATH --createClients $CREATE_CLIENTS && hermes --config $CONFIG_PATH start