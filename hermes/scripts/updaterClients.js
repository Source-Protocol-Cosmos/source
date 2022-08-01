const shell = require("shelljs");
const yargs = require("yargs");
const officials = require("../clients/officials.json");
const updateClient = require("./updateClient");

// Colors
const endColor = "\033[0m";
const blueColor = "\033[0;34m";

const argv = yargs.command("configPath", "").argv;

const configPath = argv.configPath;

shell.echo(
  `${blueColor}--------------- ${new Date()} Starting clients updater -------------------${endColor}`
);

officials.forEach(
  ({ sourceChain, cpChain, sourceRpc, cpRpc, sourceClientId, cpClientId }) => {
    updateClient({
      configPath,
      chain: sourceChain,
      client: sourceClientId,
      rpc: cpRpc,
    });
    updateClient({
      configPath,
      chain: cpChain,
      client: cpClientId,
      rpc: sourceRpc,
    });
  }
);
