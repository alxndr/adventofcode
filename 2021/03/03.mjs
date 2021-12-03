import {readFile} from '../helpers.file.mjs'

const data = (await readFile('./input.txt')).split(/\n+/)

const mostCommonBits = data.reduce((mCB, elem, index) => {
  const bits = elem.split('')
  bits.forEach((bit, nthBit) => {
    mCB[nthBit] || (mCB[nthBit] = {['0']: 0, ['1']: 0})
    mCB[nthBit][bit] += 1
  })
  return mCB
}, [])

global.console.log(mostCommonBits)

const gamma = mostCommonBits.map((counts) => counts['0'] > counts['1'] ? '0' : '1').join('')
const epsilon = mostCommonBits.map((counts) => counts['0'] > counts['1'] ? '1' : '0').join('')

const gammaDec = parseInt(gamma, 2)
const epsilonDec = parseInt(epsilon, 2)

global.console.log({
  gamma,
  gammaDec,
  epsilon,
  epsilonDec,
  powerConsumption: gammaDec * epsilonDec,
})

