function summingReducer(acc, elem) {
  // console.log(`reducing... ${acc}... ${elem}`);
  if (Array.isArray(elem)) {
    // console.log(`summing up array: ${elem}`);
    return acc + elem.reduce(summingReducer, 0);
  }
  if (typeof elem == "object" && elem) { // not null
    let elemKeys = Object.keys(elem);
    // console.log(`summing up object: ${JSON.stringify(elem)}`);
    return acc + elemKeys.map(function(elemKey) { return elem[elemKey]; }).reduce(summingReducer, 0);
  }
  if (elem) {
    if (parseInt(elem) == elem) {
      // console.log(`${acc} + ${elem}`);
      return acc + elem;
    }
  }
  // console.log(`doesn't look like nothin: ${elem}... sum still at ${acc}`);
  return acc;
}

if (process.argv[2]) {
  let contents = require("fs").readFileSync(process.argv[2]);
  // console.log(`contents: ${contents}`);
  let sum = JSON.parse(contents).reduce(summingReducer, 0);
  console.log(`sum of ints: ${sum}`);
} else {
  console.log("need a json file to process...");
}
