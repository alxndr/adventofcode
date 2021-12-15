import {readFile} from '../helpers.file.mjs'
const input = (await readFile('./input-short.txt')).split(/\n/)

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


const sum = input.reduce((n, inputLine) => {
  if (!(inputLine?.length)) return n
  // "within an entry, the same wire/segment connections are used"
  // ...but the input strings aren't in the same order!
  const segments = [] // element is the for-sure signal for the index value
  const byLength = [] // element is array of signals which are as long as the index value
  const mapping = {} // final results... single-letter segment: key is correct output segment, value is scrambled input; signal string: key is scrambled input, value is corresponding numerical value
  function record(n, signal) {
    mapping[signal] = n
    segments[n] = signal.split('')
    if (!mapping.A && segments[1] && segments[7]) {
      // segment A is in 7 but not 1
      mapping.A = segments[7].find(letter => !segments[1].includes(letter))
    }
    if (!mapping.B && segments[3] && segments[9]) {
      // mapping.B is in 9 but not 3
      mapping.B = segments[9].find(segmentInNine => !segments[3].includes(segmentInNine))
    }
    if (!segments[6] && segments[1] && byLength[6]?.length === 3) {
      // we can determine the mappings for segments C and F (which comprise "1") by looking at the segments
      // that are six letters long; the one representing 6 will contain only one of the segments in 1
      const stringForSix = byLength[6].find(signal => !segments[1].every(segmentInOne => signal.includes(segmentInOne)))
      if (stringForSix) {
        segments[mapping[stringForSix] = 6] = stringForSix.split('')
        // remove from list of byLength possibilies:
        byLength[6] = byLength[6].filter(signalString => signalString !== segments[6].join(''))
        global.console.log('tryna find C now...', segments)
        const segmentC = segments[1].find(segmentInOne => !segments[6].includes(segmentInOne)) // undefined???
        if (segmentC) {
          mapping.C = segmentC
          mapping.F = segmentC === segments[1][0] ? segments[1][1] : segments[1][0]
        }
      }
    }
    if (!mapping.D && segments[0] && segments[4]) {
      // 4 has a segment that's not in 0; mapping.D is in 4 but not 0
      mapping.D = segments[4].find(segmentInFour => !segments[0].includes(segmentInFour))
    }
    if (!mapping.E && segments[8] && segments[9]) {
      mapping.E = segments[8].find(segmentInEight => !segments[9].includes(segmentInEight))
    }
    // if (!mapping.G && Object.values(mapping).length === 6) {
    //   mapping.G = segments[8].find(segmentInEight => !Object.values(mapping).includes(segmentInEight))
    // }
    if (!segments[2] && byLength[5]?.length && mapping.F) {
      const stringForTwo = byLength[5].find(signalString => !signalString.includes(mapping.F))
      if (stringForTwo) {
        segments[mapping[stringForTwo] = 2] = stringForTwo.split('')
        // remove from list of byLength possibilies:
        byLength[5] = byLength[5].filter(signalString => signalString !== segments[2].join(''))
      }
    }
    if (!segments[5] && byLength[5]?.length && mapping.C) {
      const stringForFive = byLength[5].find(signalString => !signalString.includes(mapping.C))
      if (stringForFive) {
        segments[mapping[stringForFive] = 5] = stringForFive.split('')
        // remove from list of byLength possibilies:
        byLength[5] = byLength[5].filter(signalString => signalString !== segments[5].join(''))
      }
    }
    if (segments[3] && !segments[9] && byLength[6]?.length) {
      const stringForNine = byLength[6].find(signalString => segments[3].every(segmentInThree => signalString.split('').includes(segmentInThree)))
      if (stringForNine) {
        segments[mapping[stringForNine] = 9] = stringForNine.split('')
        // remove from list of byLength possibilies:
        byLength[6] = byLength[6].filter(signalString => signalString !== segments[9].join(''))
      }
    }
    if (!mapping.B && !mapping.E && mapping.C && mapping.F && byLength[5]?.length) {
      // byLength[5].
    }
    // if (byLength[5]?.length === 1) { // how to know this is 5??
    //   const stringForThree = byLength[5].pop()
    //   segments[mapping[stringForThree] = 3] = stringForThree.split('')
    //   // remove from list of byLength possibilies:
    //   delete byLength[5]
    // }
    // if (byLength[6]?.length === 1) { // how do we know this is 0??
    //   segments[0] = byLength[6].pop().split('')
    //   // remove from list of byLength possibilies
    //   delete byLength[6]
    // }
    return n
  }
  function recordMultiplePossibilities(signal) {
    byLength[signal.length] ||= []
    byLength[signal.length].push(signal)
    return signal
  }
  function analyze(signal) {
    const signalString = signal.split('').sort().join('') // alphabetize
    switch (signalString.length) {
      case 2: return record(1, signalString)
      case 3: return record(7, signalString)
      case 4: return record(4, signalString)
      case 5: return recordMultiplePossibilities(signalString) // [2,3,5]
      case 6: return recordMultiplePossibilities(signalString) // [0,6,9]
      case 7: return record(8, signalString)
    }
  }
  const [uniqueSignals, outputVals] = inputLine.split(' | ')
  const signalsSorted = uniqueSignals.split(' ').map(analyze)
  const outputSorted = outputVals.split(' ').map(analyze)
  // global.console.log(signalsSorted, outputSorted)
  global.console.log(mapping)
  global.console.log(outputSorted.map(outputSignal => {
    if (typeof outputSignal === 'number') {
      return outputSignal // able to identify this digit in the first pass
    }
    global.console.log('need to look up...', outputSignal)
  }))
  // if (Object.values(mapping).length !== 7) {
  //   global.console.log(inputLine)
  //   global.console.log(segments)
  //   global.console.log(byLength)
  // }
  global.console.log('\n')
  return n.concat({signalsSorted, outputSorted})
}, [])
