import {readFile} from '../helpers.file.mjs'
const input = (await readFile('./input.txt')).split(/\n/).slice(-2)
global.console.log(input[0])

// "mixed up separately for each four-digit display"

const outputNumbers = (input.filter(Boolean).map((inputLine) => {
  if (!(inputLine?.length)) return
  // "within an entry, the same wire/segment connections are used"
  // ...but the input strings aren't in the same order!
  const segments = [] // element is (array of) the for-sure signal for the index value
  // segments[8] = ['a', 'b', 'c', 'd', 'e', 'f', 'g']
  const byLength = [] // element is (array of) signals which are as long as the index value
  const mapping = {} // final results... single-letter segment: key is correct output segment, value is scrambled input; signal string: key is scrambled input, value is corresponding numerical value
  function reckon(quit = false) {
    if (quit) return
    if (!segments[0] && mapping.D && segments[8]) {
      // if no segments[0] but we do have mapping.D, subtract it from segments for 8
      const stringForZero = segments[8].filter(segmentInEight => segmentInEight !== mapping.D).join('')
      segments[mapping[stringForZero] = 0] = stringForZero.split('')
      // remove from list of byLength possibilies:
      byLength[6] = byLength[6].filter(signalString => signalString !== segments[0].join(''))
    }
    if (!segments[2] && byLength[5]?.length === 3 && mapping.F) {
      const stringForTwo = byLength[5].find(signalString => !signalString.includes(mapping.F))
      if (stringForTwo) {
        segments[mapping[stringForTwo] = 2] = stringForTwo.split('')
        // remove from list of byLength possibilies:
        byLength[5] = byLength[5].filter(signalString => signalString !== stringForTwo)
      }
    }
    if (!segments[3] && byLength[5]?.length === 1 && segments[2] && segments[5]) {
      const signalForThree = byLength[5].find(signalString => signalString !== segments[2].join('') && signalString !== segments[5].join(''))
      segments[mapping[signalForThree] = 3] = signalForThree.split('')
    }
    if (!segments[3] && segments[2] && segments[5]) {
      const signalForThree = byLength[5].find(signalFiveLong => signalFiveLong !== segments[2].join('') && signalFiveLong !== segments[5].join(''))
      segments[mapping[signalForThree] = 3] = signalForThree.split('')
      // remove from list of byLength possibilies:
      byLength[5] = byLength[5].filter(signalString => signalString !== signalForThree)
      // // removing byLength[5] entirely now...
      // delete byLength[5]
    }
    if (!segments[5] && byLength[5]?.length === 3 && mapping.C) {
      const stringForFive = byLength[5].find(signalString => !signalString.includes(mapping.C))
      if (stringForFive) {
        segments[mapping[stringForFive] = 5] = stringForFive.split('')
        // remove from list of byLength possibilies:
        byLength[5] = byLength[5].filter(signalString => signalString !== stringForFive)
      }
    }
    if (!segments[6] && segments[1] && byLength[6]?.length === 3) {
      // of the input codes which are 6 letters long, only one of them (the one representing 6)
      // will have all of the segments from the input code for 1
      const stringForSix = byLength[6].find(signal => !segments[1].every(segmentInOne => signal.includes(segmentInOne)))
      if (stringForSix) {
        segments[mapping[stringForSix] = 6] = stringForSix.split('')
        // remove from list of byLength possibilies:
        byLength[6] = byLength[6].filter(signalString => signalString !== stringForSix)
      }
    }
    if (!segments[9] && segments[3] && byLength[6]?.length === 3) { // not working... 3 and 9 can't depend on each other
      // of input codes 6-letters-long, only one (the code for 9) will include all of the segments in the code for 3
      const signalForNine = byLength[6].find(signalSixLong => segments[3].every(segmentInThree => signalSixLong.includes(segmentInThree)))
      if (signalForNine) {
        segments[mapping[signalForNine] = 9] = signalForNine.split('')
        // remove from list of byLength possibilies:
        byLength[6] = byLength[6].filter(signalString => signalString !== signalForNine)
      }
    }
    // if (outputSignal.length === 6 && !segments[9] && segments[0] && segments[6]) {
    //   segments[mapping[outputSignal] = 9] = outputSignal.split('')
    //   return 9
    // }
    if (!mapping.A && segments[1] && segments[7]) {
      // segment A is in 7 but not 1
      mapping.A = segments[7].find(letter => !segments[1].includes(letter))
    }
    if (!mapping.B && segments[3] && segments[9]) {
      // mapping.B is in 9 but not 3
      mapping.B = segments[9].find(segmentInNine => !segments[3].includes(segmentInNine))
    }
    if ((!mapping.B || !mapping.D) && segments[1] && segments[4] && byLength[6]?.length === 3) {
      // 2 segments are in 4 but not 1
      const twoSegments = segments[4].filter(segmentInFour => !segments[1].includes(segmentInFour))
      // of those segments, one is in every 6-long code (B) and one is not (D is not in 0)
      mapping.B = twoSegments.find(segment => byLength[6].every(signalSixLong => signalSixLong.includes(segment)))
      mapping.D = mapping.B === twoSegments[0] ? twoSegments[1] : twoSegments[0]
    }
    if ((!mapping.C || !mapping.F) && segments[1] && segments[6]) {
      // we can determine the mappings for segments C and F (which comprise "1") by looking at the input codes
      // which are six letters long; the one representing 4 will contain only one of the segments in 1
      mapping.C = segments[1].find(segmentInOne => !segments[6].includes(segmentInOne))
      if (!mapping.C) throw new Error('should be able to find C')
      mapping.F = mapping.C === segments[1][0] ? segments[1][1] : segments[1][0]
    }
    if (!mapping.D && segments[0] && segments[4]) {
      // 4 has a segment that's not in 0; mapping.D is in 4 but not 0
      mapping.D = segments[4].find(segmentInFour => !segments[0].includes(segmentInFour))
    }
    if (!mapping.E && segments[8] && segments[9]) { // TODO
      mapping.E = segments[8].find(segmentInEight => !segments[9].includes(segmentInEight))
    }
    if (!mapping.G && segments[5] && segments[4] && mapping.A) {
      const twoSegments = segments[5].filter(segmentInFive => !segments[4].includes(segmentInFive))
      mapping.G = twoSegments.find(segment => segment !== mapping.A)
    }
    reckon(true)
  }
  function record(n, signal) { // mutates `segments` and `mapping` and then calls `reckon`
    segments[mapping[signal] = n] = signal.split('')
    reckon()
    return n
  }
  function recordMultiplePossibilities(signal) { // mutates `byLength` and calls `reckon`
    byLength[signal.length] ||= []
    byLength[signal.length].push(signal)
    reckon()
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
  const interpreted = (outputSorted.map(outputSignal => {
    if (typeof outputSignal === 'number') {
      return outputSignal // able to identify this digit in the first pass
    }
    if (mapping.hasOwnProperty(outputSignal))
      return mapping[outputSignal]
    // if (outputSignal.split('').every(signalLetter => Object.value()))
    global.console.log('oh no...', outputSignal, mapping)
    return outputSignal
  }))
  global.console.log(interpreted)
    global.console.log('\n')
  return Number(interpreted.map(String).join(''))
}))

global.console.log('sum', outputNumbers.reduce((a, b) => a + b))
