const _ = require("lodash");

function summingReducer(acc, elem) {
  if (Array.isArray(elem)) {
    return acc + elem.reduce(summingReducer, 0);
  }
  if (typeof elem == "object" && elem) {
    let values = _.values(elem);
    if (values.indexOf("red") != -1) {
      return acc; // skip any objects which contain a value of "red"
    }
    return acc + values.reduce(summingReducer, 0);
  }
  if (elem) {
    if (parseInt(elem) == elem) {
      return acc + elem;
    }
  }
  return acc;
}

if (process.argv[2]) {
  const contents = require("fs").readFileSync(process.argv[2]);
  const sum = JSON.parse(contents).reduce(summingReducer, 0);
  console.log(`sum of ints: ${sum}`);
} else {
  console.log("need a json file to process...");
}
