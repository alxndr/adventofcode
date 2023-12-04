#!/usr/bin/env node
import {readFileSync} from 'fs'
const input = (await readFileSync('input.txt', 'utf-8'))
  .split(/\r?\n/)
if (!input[input.length-1].length) input.pop() // trim a POSIX trailing newline

const RE_SPACES = /\s+/

const numMatches = {}

global.console.log(
  'result? ', input.reduce((acc, elem, index) => {
    numMatches[index] = 0
    const [_, card] = elem.split(/:\s+/)
    const [winners, hand] = card.split(' | ')
    const winnersArr = winners.split(RE_SPACES)
    const handArr = hand.split(RE_SPACES)
    handArr.map(handNumStr => {
      if (winnersArr.includes(handNumStr)) {
        numMatches[index]++
      }
    })
    if (numMatches[index]) {
      return acc + (2 ** (numMatches[index] - 1));
    }
    return acc
  }, 0)
)
