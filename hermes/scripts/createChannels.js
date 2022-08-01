const shell = require("shelljs");

function createChannels({ configPath, sourceChain, sourceConnection }) {
  // Colors
  const endColor = "\033[0m";
  const greenColor = "\033[0;32m";
  const yellowColor = "\033[0;33m";

  shell.echo(
    `${greenColor}--------------- CREATING HERMES CHANNELS -------------------${endColor}\n`
  );

  shell.echo(`${yellowColor}Info:${endColor} creating channels`);

  const { stdout } = shell.exec(
    `hermes --config ${configPath} create channel --a-chain ${sourceChain} --a-connection ${sourceConnection} --a-port transfer --b-port transfer`
  );
  const [sourceChannel, cpChannel] = stdout.match(/channel-[0-9]*/g);
  if (sourceChannel && cpChannel) {
    return { sourceChannel, cpChannel };
  }
}

module.exports = createChannels;
