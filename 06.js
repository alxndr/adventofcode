const readline = require('readline');

const RE_INSTRUCTIONS = /(turn on|toggle|turn off) (\d+,\d+) through (\d+,\d+)/;

function interpretInstructions(lights, instructions) {
  let instructionSet = RE_INSTRUCTIONS.exec(instructions);
  if (!instructionSet) {
    process.stderr.write("uh oh, returning false");
    return false;
  }
  let directive = instructionSet[1];
  let startCoords = extractCoords(instructionSet[2].split(","));
  let endCoords = extractCoords(instructionSet[3].split(","));
  console.log(`light count was... ${countLights(lights)}`);
  var newLights;
  switch (directive) {
  case "turn on":
    newLights = turnOn(lights, startCoords, endCoords);
    break;
  case "turn off":
    newLights = turnOff(lights, startCoords, endCoords);
    break;
  case "toggle":
    newLights = toggle(lights, startCoords, endCoords);
    break;
  default:
    process.stderr.write(`uhhhh what is this? ${directive}`);
    break;
  }
  console.log(`now light count is: ${countLights(newLights)}`);
  return newLights;
}

function turnOn(l, begin, finish) {
  // console.log(`gonna turn on ${begin.y} to ${finish.y}, within every row from ${begin.x} to ${finish.x}`);
  for (let i = begin.x; i < finish.x; i++) {
    if (!l[i]) { l[i] = new Array(999); }
    for (let j = begin.y; j < finish.y; j++) {
      l[i][j] = 1;
    }
    // console.log(`done with row ${i}`);
  }
  return l;
}

function turnOff(l, begin, finish) {
  for (let i = begin.x; i < finish.x; i++) {
    if (!l[i]) { l[i] = new Array(999); }
    for (let j = begin.y; j < finish.y; j++) {
      l[i][j] = 0;
    }
  }
  return l;
}

function toggle(l, begin, finish) {
  for (let i = begin.x; i < finish.x; i++) {
    if (!l[i]) { l[i] = new Array(999); }
    for (let j = begin.y; j < finish.y; j++) {
      if (l[i][j] == 0)
        l[i][j] = 1;
      else
        l[i][j] = 0;
    }
  }
  return l;
}

function extractCoords(coords) {
  return {
    x: coords[0],
    y: coords[1]
  };
}

function countEm(sum, elem) {
  if (elem)
    return sum + 1;
  return sum;
}

function countLights(lights) {
  return lights.reduce(function(sum, lightsRow) {
    return sum + lightsRow.reduce(countEm, 0);
  }, 0);
}

var rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

var lines = [];

rl.on("line", function(line) {
  lines.push(line);
});

rl.on("close", function() {
  var things = [[]];
  for (var line in lines) {
    things = interpretInstructions(things, line);
  }
  console.log(countLights(things));
});
