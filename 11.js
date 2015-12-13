const regexHasBadLetters = /[ilo]/;
const regexHasTwoDoubleSequences = /(.)\1.*(?!\1)(.)\2/;
const regexNonAlphabeticalChars = /[^a-z]/;

function isMatchingNewPasswordRules(pw) {
  // process.stdout.write(`${pw}... `);
  const hasBadLetters = regexHasBadLetters.test(pw);
  if (hasBadLetters) {
    // process.stdout.write(`no good, has bad letters\n`);
    return false;
  }
  if (!regexHasTwoDoubleSequences.test(pw)) {
    // process.stdout.write(`no good, missing doubles... ${pw}...${hasBadLetters}\n`);
    return false;
  }
  if (!includesSequence(pw)) {
    // process.stdout.write(`no good, missing three-part sequence\n`);
    return false;
  }
  return true;
}

function isLetterFollowedBySequence(letter, index, string) {
  let startingCharCode = letter.charCodeAt(0);
  return string[index+1] &&
    string[index+2] &&
    string[index+1].charCodeAt(0) == startingCharCode + 1 &&
    string[index+2].charCodeAt(0) == startingCharCode + 2;
}

function includesSequence(pw) {
  return pw.split("").some(isLetterFollowedBySequence);
}

let succ = require("underscore.string/succ");
function findNextString(string) {
  // would be ideal to split string into chars, find numerical value for each char within window, increment (w/carries), then convert back to chars
  let succ_str = succ(string);
  if (!regexNonAlphabeticalChars.test(succ_str)) {
    return succ_str;
  }
  return succ_str.split("").reverse().reduce(function(acc, elem, index, arr) {
    if (regexNonAlphabeticalChars.test(elem)) {
      acc.push("a");
      arr[index+1] = succ(arr[index+1]);
    } else {
      acc.push(elem);
    }
    return acc;
  }, []).reverse().join("");
}

if (process.argv) {
  var pw = process.argv[2];
  var counter = 0;
  while (!isMatchingNewPasswordRules(pw) && counter++ < 9999999) {
    // let startingStr = `pw ${pw} no good, trying next... `;
    pw = findNextString(pw);
    // console.log(`${startingStr} ${pw}`);
    // process.stdout.write(".");
  }
  // process.stdout.write("\n");
  if (isMatchingNewPasswordRules(pw)) {
    process.stdout.write(`this pw should be good: ${pw}\n`);
  } else {
    process.stdout.write(`timed out... got as far as ${pw}\n`);
  }
}
