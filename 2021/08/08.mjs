const correctMappings = [
  'abcefg',  // 0 has 6 segments
  'cf',      // 1 ... 2     <- unique
  'acdeg',   // 2 ... 5
  'acdfg',   // 3 ... 5
  'bcdf',    // 4 ... 4     <- unique
  'abdfg',   // 5 ... 5
  'abdefg',  // 6 ... 6
  'acf',     // 7 ... 3     <- unique
  'abcdefg', // 8 ... 7     <- unique
  'abcdfg',  // 9 ... 6
]

const binaryMappings = [
  0b1110111, // 0 has 6 segments       "119"
  0b0010010, // 1 ... 2     <- unique  "18"
  0b1011101, // 2 ... 5                "93"
  0b1011011, // 3 ... 5                "91"
  0b0111010, // 4 ... 4     <- unique  "58"
  0b1101011, // 5 ... 5                "107"
  0b1101111, // 6 ... 6                "111"
  0b1010010, // 7 ... 3     <- unique  "82"
  0b1111111, // 8 ... 7     <- unique  "127"
  0b1111011, // 9 ... 6                "123"
]

// "mixed up separately for each four-digit display"

import {readFile} from '../helpers.file.mjs'
const input = (await readFile('./input.txt')).split(/\n/)
const sum = input.reduce((n, inputLine) => {
  if (!(inputLine?.length)) return n
  // "within an entry, the same wire/segment connections are used"
  const [uniqueSignals, outputVal] = inputLine.split(' | ')
  const note = {uniqueSignals, outputVal}
  return n + outputVal.split(' ').map(str => str.length).filter(len => [2, 4, 3, 7].includes(len)).length
}, 0)

global.console.log({sum})
