# SSL sidecar

## Introduction

The SSL is added using a nginx sidecar in the docker compose file. The sidecar uses the nginx config file present in nginx/config/, which is prepared to use the certificates provided by let encrypt. The certbot can be used from the host to provide the certificates, and the nginx should be able to access them.
