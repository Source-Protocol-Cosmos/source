FROM hermes_img

# crontab schedule
COPY clients-updater-cron root

# cron install
RUN apt update && apt install -y --no-install-recommends cron && rm -rf /var/lib/apt/lists/*
RUN crontab root

# node
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN apt update && apt install -y --no-install-recommends nodejs

# Add enviroments to cron, add address in hermes and run cron
CMD bash -c printenv | grep -v "no_proxy" >>"/etc/environment" && npm install && node ./scripts/createRelayer.js --configPath $CONFIG_PATH --mnemonicPath $MNEMONIC_PATH --createClients false -z false && cron && tail -f /var/log/clients-updater.log