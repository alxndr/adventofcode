import {readFile} from '../helpers.file.mjs'

function partitionByBitFrequency(input, nthBit) {
  return input.reduce((acc, row) => {
    if (!(row?.length)) return acc
    const bit = row.slice(nthBit, nthBit + 1)
    return {
      '0': bit === '0' ? acc['0'].concat(input) : acc['0'],
      '1': bit === '1' ? acc['1'].concat(input) : acc['1'],
    }
  }, {'0': [], '1': []})
}

function analyzeBitMostCommon(data, bit) {
  if (data?.length === 1) return data
  const partitioned = partitionByBitFrequency(data, bit)
  if (partitioned['0'].length > partitioned['1'].length)
    return data.filter(datum => datum.slice(bit, bit+1) === '0')
  return data.filter(datum => datum.slice(bit, bit+1) === '1')
}

function analyzeBitLeastCommon(data, bit) {
  if (data?.length === 1) return data
  const partitioned = partitionByBitFrequency(data, bit)
  if (partitioned['0'].length > partitioned['1'].length)
    return data.filter(datum => datum.slice(bit, bit+1) === '1')
  return data.filter(datum => datum.slice(bit, bit+1) === '0')
}

function getOxRatingRecursive(data, bit) {
  if (bit > data[0].length) return data
  if (data.length === 1) return data
  return getOxRatingRecursive(analyzeBitMostCommon(data, bit), bit + 1)
}


function getCarbonRatingRecursive(data, bit) {
  if (bit > data[0].length) return data
  if (data.length === 1) return data
  return getCarbonRatingRecursive(analyzeBitLeastCommon(data, bit), bit + 1)
}


const data = (await readFile('./input.txt')).split(/\n+/).filter(Boolean)
// const data = (await readFile('./input-short.txt')).split(/\n+/).filter(Boolean)
global.console.log('input length:', data.length)

const ox = getOxRatingRecursive(data, 0)
const oxDec = parseInt(ox[0], 2)
global.console.log('ox decimal', oxDec)

const co = getCarbonRatingRecursive(data, 0)
const coDec = parseInt(co[0], 2)
global.console.log('co2 decimal', coDec)

global.console.log('multiplied', oxDec * coDec)
