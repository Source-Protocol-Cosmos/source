const shell = require("shelljs");
const https = require("https");

function updateClient({ configPath, chain, client, rpc }) {
  // Colors
  const endColor = "\033[0m";
  const redColor = "\033[0;31m";
  const greenColor = "\033[0;32m";
  const yellowColor = "\033[0;33m";

  shell.echo(
    `\n${greenColor}--------------- TESTING HERMES PATH -------------------\n`
  );
  // Check if hermes is included in local PATH.
  // If it is not includes, the root path is assigned.
  // This is useful to use hermes either in a docker as root user or local
  const { stdout: hermesVersion } = shell.exec(`hermes --version`);
  const hermes = hermesVersion ? "hermes" : "/root/.hermes/bin/hermes";

  shell.echo(
    `\n${greenColor}--------------- GETTING LAST BLOCK and TRUSTING PERIOD FOR ${chain}-------------------\n`,
    `---------------${chain} with client ${client} -------------------${endColor}`
  );
  // Get last block and trusting period for client
  const { stdout } = shell.exec(
    `${hermes} --config ${configPath} --json query client state --chain ${chain} --client ${client}`
  );

  const {
    result: {
      latest_height: { revision_height: clientLastHeightBlock },
    },
  } = JSON.parse(stdout);
  const clientTrustingPeriod = JSON.parse(stdout).result.trusting_period.secs;

  // Get date for block
  https
    .get(`${rpc}/block?height=${clientLastHeightBlock}`, (res) => {
      let data = "";
      res.on("data", (chunk) => {
        data += chunk;
      });
      res.on("end", () => {
        data = JSON.parse(data);
        const clientLastHeightBlockTime = data.result.block.header.time;

        // Format date to US
        const clientLastHeightBlockUStime = new Date(
          new Date(clientLastHeightBlockTime).toLocaleString("en-US")
        );
        const currentUStime = new Date(new Date().toLocaleString("en-US"));

        // Difference in seconds
        const timeFromLastUpdate =
          (currentUStime.getTime() - clientLastHeightBlockUStime.getTime()) /
          1000;

        // Waiting period for client update
        const windowPeriod = timeFromLastUpdate + clientTrustingPeriod / 3;
        if (windowPeriod > clientTrustingPeriod) {
          // if (true) {
          shell.echo(
            `${greenColor}--------------- UPDATING ${client} -------------------${endColor}`
          );
          shell.exec(
            `${hermes} --config ${configPath} update client --host-chain ${chain} --client ${client}`
          );
        } else {
          shell.echo(
            `\n${yellowColor}Info:${endColor} ${chain} - ${client} not updated required`
          );
          shell.echo(
            `${yellowColor}Info:${endColor} Minutes from last update: ${
              timeFromLastUpdate / 60
            }`
          );
          shell.echo(
            `${yellowColor}Info:${endColor} Time remaining : ${
              clientTrustingPeriod / 60 - timeFromLastUpdate / 60
            }`
          );
        }
      });
    })
    .on("error", (err) => {
      shell.echo(`${redColor}${err.message}${endColor}`);
    });
}

module.exports = updateClient;
