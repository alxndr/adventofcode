#!/usr/bin/env node
import {readFileSync} from 'fs'
const input = (await readFileSync('sample.txt', 'utf-8'))
  .split(/\r?\n/)
if (!input[input.length-1].length) input.pop() // trim a POSIX trailing newline

// observations about input:
// • there are no 4-digit numbers (only possible values 1–999)
// • only one instance of a single-digit number which is one-period away from another number: ".496.9." ... and an asterisk does not occur above/below the separating period

const lines = input;
const RE_ASTERISK = /\*/g
const RE_NUMBER = /\d/
const RE_NUMBERS_AT_BEGINNING = /^\d+/
const RE_NUMBERS_AT_END = /\d+$/
const RE_NUMBERS_IN_SEQUENCE_OF_THREE = /^([\d.])([\d.])([\d.])$/ // relies on assumptions about input...
const RE_NUMBERS_SEPARATED_BY_PERIODS = /(\d+)\.+(\d+)/ // relies on assumptions about input...
const sum = lines.reduce((acc, line, lineIndex) => {
  let match;
  while (match = RE_ASTERISK.exec(line)) {
    const {index} = match;
    const adjacentNumbers = [];

    const strBeforeMatch = line.slice(0, index)
    const numberBefore = strBeforeMatch.match(RE_NUMBERS_AT_END)?.[0]
    if (numberBefore)
      adjacentNumbers.push(Number(numberBefore))

    const strAfterMatch = line.slice(index + 1)
    const numberAfter = strAfterMatch.match(RE_NUMBERS_AT_BEGINNING)?.[0]
    if (numberAfter)
      adjacentNumbers.push(Number(numberAfter))

    if (lineIndex > 0) { // check above
      const lineAbove = lines[lineIndex-1];
      const aboveSequence = lineAbove.slice(index - 1, index + 2) // TODO account for L and R edges...
      global.console.log({index, lineIndex, aboveSequence})
      // there are 8 optns for above (and below):
        // .#. = push
        // ##. = grab 1 left
        // .## = grab 1 right
        // ### = push
      if (aboveSequence === '...') {
        // ... = next
        'no-op';
      } else {
        global.console.log({aboveSequence})
        const [_, a, b, c] = aboveSequence.match(RE_NUMBERS_IN_SEQUENCE_OF_THREE)
        if (b === '.') {
          // #.# = grab 2 left thru 2 right
          // #.. = grab 2 left
          // ..# = grab 2 right
          const numberMatches = lineAbove.slice(index - 3, index + 4).match(RE_NUMBERS_SEPARATED_BY_PERIODS)
          global.console.log({numberMatches})
          adjacentNumbers.concat(numberMatches)
        }
      }
    }
    if (lines[lineIndex+1]) { // check below
    }

    if (adjacentNumbers.length) {
      global.console.log('* (%d,%d) adjacent:', index, lineIndex, adjacentNumbers)
    } else
      global.console.log('* (%d,%d)', index, lineIndex)
  }
  return acc

}, 0)

global.console.log({sum})
