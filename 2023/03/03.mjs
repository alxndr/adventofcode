#!/usr/bin/env node
import {readFileSync} from 'fs'
const input = (await readFileSync('input.txt', 'utf-8')).split(/\r?\n/)
if (!input[input.length-1].length) input.pop() // trim a POSIX trailing newline

const lines = input;
const RE_NUMBERS = /\d+/g
const sum =
lines.reduce((acc, line, lineIndex) => {
  let match;
  while (match = RE_NUMBERS.exec(line)) {
    const {index} = match;
    const [valString] = match;
    global.console.log('%d @ %d,%d', valString, index, lineIndex)
    let isAnIsland = true;
    if (index > 0 && line[index - 1] !== '.') {
      global.console.log('nope...1')
      isAnIsland = false;
    } else if (index + valString.length < line.length &&
        line[index + valString.length] !== '.') {
      global.console.log('nope...2', line[index + valString.length])
      isAnIsland = false;
    } else for (let charIndex = Math.max(0, index - 1);
      charIndex < Math.min(index + valString.length + 1, line.length);
      charIndex++) {
      // global.console.log({charIndex,
      //   '-1':lines[lineIndex-1]?.[charIndex],
      //   '+1':lines[lineIndex+1]?.[charIndex],
      // })
      if (lines[lineIndex-1] && lines[lineIndex-1][charIndex] !== '.') {
        isAnIsland = false;
        continue;
      }
      if (lines[lineIndex+1] && lines[lineIndex+1][charIndex] !== '.') {
        isAnIsland = false;
        continue;
      }
    }
    // global.console.log({
    //   isAnIsland,
    //   a:index > 0 && line[index-1],
    //   b: index + valString.length < line.length && line[index + valString.length],
    // })
    global.console.log({isAnIsland, valString, n:Number(valString)})
    if (!isAnIsland)
      acc = acc + Number(valString)
    global.console.log({acc})
  }
  return acc

}, 0)

global.console.log({sum})
