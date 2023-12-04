#!/usr/bin/env node
import {readFileSync} from 'fs'
const input = (await readFileSync('input.txt', 'utf-8'))
  .split(/\r?\n/)
if (!input[input.length-1].length) input.pop() // trim a POSIX trailing newline

const RE_SPACES = /\s+/

const numMatches = {}
const numCards = Array(input.length).fill(1)

input.map((line, index) => {
  numMatches[index] = 0
  const [_, card] = line.split(/:\s+/)
  const [winners, hand] = card.split(' | ')
  const winnersArr = winners.split(RE_SPACES)
  const handArr = hand.split(RE_SPACES)
  handArr.map(handNumStr => {
    if (winnersArr.includes(handNumStr)) {
      numMatches[index]++
    }
  })
  for (let i = 1; i <= numMatches[index]; i++) {
    global.console.log('there are %d matches... and we have %d of this card...', numMatches[index], numCards[index])
    numCards[index+i] = numCards[index+i] + numCards[index]
  }
  global.console.log('idx:%d (%d) \t %s', index, numCards[index], numCards.slice(index, index+5))
})
global.console.log(numCards.reduce((sum, n) => sum + n))
