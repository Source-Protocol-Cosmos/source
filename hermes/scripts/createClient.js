const shell = require("shelljs");

function createClient({ configPath, sourceChain, cpChain }) {
  // Colors
  const endColor = "\033[0m";
  const greenColor = "\033[0;32m";
  const yellowColor = "\033[0;33m";

  shell.echo(
    `${greenColor}--------------- CREATING HERMES CLIENTS -------------------${endColor}\n`
  );

  // Source client
  shell.echo(`${yellowColor}Info:${endColor} creating ${cpChain} client`);

  const { stdout } = shell.exec(
    `hermes --config ${configPath} tx raw create-client --host-chain ${sourceChain} --reference-chain ${cpChain}`
  );
  const sourceClientId = stdout.match(/07-tendermint-[0-9]*/g);

  // Counter party client
  shell.echo(`${yellowColor}Info:${endColor} creating ${sourceChain} client`);

  const { stdout: cpStdout } = shell.exec(
    `hermes --config ${configPath} tx raw create-client --host-chain ${cpChain} --reference-chain ${sourceChain}`
  );
  const cpClientId = cpStdout.match(/07-tendermint-[0-9]*/g);

  if (sourceClientId[0] && cpClientId[0]) {
    return {
      sourceClientId: sourceClientId[0],
      cpClientId: cpClientId[0],
    };
  }
}

module.exports = createClient;
