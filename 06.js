const RE_INSTRUCTIONS = /(turn on|toggle|turn off) (\d+,\d+) through (\d+,\d+)/;

var lights = [];

function interpretInstructions(instructions) {
  let instructionSet = RE_INSTRUCTIONS.exec(instructions);
  if (!instructionSet) {
    return false;
  }
  console.log(instructionSet);
  // ignoring the Y-axis for now...
  let directive = instructionSet[0];
  let [x1, y1] = instructionSet[1].split(",");
  let [x2, y2] = instructionSet[2].split(",");
  return lights;
}

process.stdin.on("readable", function() {
  let line = process.stdin.read();
  if (line !== null) {
    interpretInstructions(line);
  } else {
    process.stdout.write(lights);
  }
});
