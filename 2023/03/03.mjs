#!/usr/bin/env node
import {readFileSync} from 'fs'
const input = (await readFileSync('input.txt', 'utf-8'))
  .replace(/\./g, " ") // use spaces rather than periods...
  .split(/\r?\n/)
if (!input[input.length-1].length) input.pop() // trim a POSIX trailing newline

// observations about input:
// • there are no 4-digit numbers (only possible values 1–999)
// • only one instance of a single-digit number which is one-period away from another number: ".496.9." ... and an asterisk does not occur above/below the separating period

const lines = input;
const RE_ASTERISK = /\*/g
const RE_NUMBER = /\d/
const sum = lines.reduce((acc, line, lineIndex) => {
  let match;
  while (match = RE_ASTERISK.exec(line)) {
    const starIndex = match.index;
    const adjacentNumbers = []

    if (lineIndex > 0) {
      const lineAbove = lines[lineIndex-1]
      const charAboveAsterisk = lineAbove[starIndex]
      if (charAboveAsterisk === ' ') {
        const beforeAsterisk = lineAbove.substring(starIndex-3, starIndex)
        const beforeMatch = beforeAsterisk.match(/(\d+)$/)
        if (beforeMatch) {adjacentNumbers.push(beforeMatch[1])}
        const afterAsterisk = lineAbove.substring(starIndex+1, starIndex+4)
        const afterMatch = afterAsterisk.match(/^(\d+)/)
        if (afterMatch) {adjacentNumbers.push(afterMatch[1])}
      } else {
        // char Above is a number...
        const aboveMatch = lineAbove.substring(starIndex-2, starIndex+3).match(/.?.?\b(\d+)\b.?.?/)?.[1]
        if (aboveMatch) adjacentNumbers.push(aboveMatch)
      }

    }

    const middleLine = line.substring(starIndex-3, starIndex+4);
    const beforeMatch = middleLine.match(/(\d+)\*/)
    if (beforeMatch) adjacentNumbers.push(beforeMatch[1])
    const afterMatch = middleLine.match(/\*(\d+)/)
    if (afterMatch) adjacentNumbers.push(afterMatch[1])

    if (lineIndex < lines.length - 1) {
      const lineBelow = lines[lineIndex+1]
      const charBelowAsterisk = lineBelow[starIndex]
      if (charBelowAsterisk === ' ') {
        const beforeAsterisk = lineBelow.substring(starIndex-3, starIndex)
        const beforeMatch = beforeAsterisk.match(/(\d+)$/)
        if (beforeMatch) {adjacentNumbers.push(beforeMatch[1])}
        const afterAsterisk = lineBelow.substring(starIndex+1, starIndex+4)
        const afterMatch = afterAsterisk.match(/^(\d+)/)
        if (afterMatch) {adjacentNumbers.push(afterMatch[1])}
      } else {
        // char below is a number...
        const belowMatch = lineBelow.substring(starIndex-2, starIndex+3).match(/.?.?\b(\d+)\b.?.?/)?.[1]
        if (belowMatch) adjacentNumbers.push(belowMatch)
      }
    }

    global.console.log('(%d,%d): %s', starIndex, lineIndex, adjacentNumbers.join(','))

    if (adjacentNumbers.length === 2) {
      const gearRatio = Number(adjacentNumbers[0]) * Number(adjacentNumbers[1])
      acc += gearRatio;
    }
  }
  return acc

}, 0)

global.console.log({sum})
