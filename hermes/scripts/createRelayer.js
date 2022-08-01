const fs = require("fs");
const shell = require("shelljs");
const toml = require("@iarna/toml");
const officials = require("../clients/officials.json");
const yargs = require("yargs");

const addKeys = require("./addKeys");
const createClient = require("./createClient");
const createConnections = require("./createConnections");
const createChannels = require("./createChannels");

// Colors
const endColor = "\033[0m";
const greenColor = "\033[0;32m";

const argv = yargs
  .command("configPath", "")
  .command("mnemonicPath", "")
  .command("createClients", "").argv;

const configPath = argv.configPath;
const mnemonicPath = argv.mnemonicPath;
const createClients = argv.createClients;

const { chains } = toml.parse(fs.readFileSync(configPath, "utf-8"));

const [sourceAddress, cpAddress] = chains.map(({ id }) => {
  return addKeys({ configPath, mnemonicPath, chainId: id });
});

if (createClients === "true") {
  // Current source chain id
  const { id: sourceChain, rpc_addr: sourceRpc } = chains.filter(
    ({ account_prefix }) => account_prefix === "source"
  )[0];

  chains
    .filter(({ id }) => id !== sourceChain)
    .forEach(({ id: cpChain, rpc_addr: cpRpc }) => {
      // Creating clients
      const { sourceClientId, cpClientId } = createClient({
        configPath,
        sourceChain,
        cpChain,
      });

      // Creating connections
      const { sourceConnection, cpConnection } = createConnections({
        configPath,
        sourceClientId,
        cpClientId,
        sourceChain,
        cpChain,
      });

      // Creating channels
      const { cpChannel, sourceChannel } = createChannels({
        configPath,
        sourceChain,
        sourceConnection,
      });

      shell.echo(
        `${greenColor}--------------- CREATING FILE RESULT -------------------${endColor}\n`
      );
      officials.push({
        sourceChain,
        cpChain,
        sourceRpc,
        cpRpc,
        sourceAddress,
        cpAddress,
        sourceClientId,
        cpClientId,
        sourceConnection,
        cpConnection,
        cpChannel,
        sourceChannel,
      });
      shell.exec(
        `echo '${JSON.stringify(officials)}' > ./clients/officials.json`
      );
    });
}
