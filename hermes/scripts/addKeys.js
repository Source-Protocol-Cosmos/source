const shell = require("shelljs");

function addKeys({ configPath, mnemonicPath, chainId }) {
  // Colors
  const endColor = "\033[0m";
  const greenColor = "\033[0;32m";

  shell.echo(
    `${greenColor}--------------- ADDING HERMES KEYS FOR ${chainId} -------------------${endColor}`
  );

  const { stdout } = shell.exec(
    `hermes --config ${configPath} keys add --chain ${chainId} --mnemonic-file ${mnemonicPath}`
  );

  const address = stdout.split(" ")[4].replace(/[^a-z0-9]/g, "");
  shell.echo(`${greenColor} ${address} ${endColor}\n`);

  return address;
}

module.exports = addKeys;
