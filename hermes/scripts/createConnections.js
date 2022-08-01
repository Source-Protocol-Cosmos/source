const shell = require("shelljs");

function createConnections({
  configPath,
  sourceClientId,
  cpClientId,
  sourceChain,
  cpChain,
}) {
  // Colors
  const endColor = "\033[0m";
  const greenColor = "\033[0;32m";
  const yellowColor = "\033[0;33m";

  shell.echo(
    `${greenColor}--------------- CREATING HERMES CONNECTIONS -------------------${endColor}\n`
  );

  shell.echo(
    `${yellowColor}Info:${endColor} creating [${sourceChain} / ${cpChain}] connection`
  );

  const { stdout } = shell.exec(
    `hermes --config ${configPath} create connection --a-client ${sourceClientId} --b-client ${cpClientId} --a-chain ${sourceChain}`
  );
  const [sourceConnection, cpConnection] = stdout.match(/connection-[0-9]*/g);
  if (sourceConnection && cpConnection) {
    return { sourceConnection, cpConnection };
  }
}

module.exports = createConnections;
