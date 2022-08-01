const shell = require("shelljs");
const yargs = require("yargs");

// Colors
const endColor = "\033[0m";
const greenColor = "\033[0;32m";

const argv = yargs
  .command("configPath", "")
  .command("srcChain", "")
  .command("srcChannel", "")
  .command("dstChain", "")
  .command("denom", "")
  .command("amount", "").argv;

const configPath = argv.configPath;
const srcChain = argv.srcChain;
const srcChannel = argv.srcChannel;
const dstChain = argv.dstChain;
const denom = argv.denom;
const amount = argv.amount;

shell.echo(
  `${greenColor}--------------- TRANSFER TOKENS -------------------${endColor}`
);
shell.echo(
  `${greenColor} ${amount}${denom} from ${srcChain} to ${dstChain} ${endColor}`
);
shell.exec(
  `hermes --config ${configPath} tx raw ft-transfer --dst-chain ${dstChain} --src-chain ${srcChain} --src-port transfer --src-channel ${srcChannel} --amount ${amount} --denom ${denom} --timeout-height-offset 1000`
);
