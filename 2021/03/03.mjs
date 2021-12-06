import {readFile} from '../helpers.file.mjs'

const data = (await readFile('./input.txt')).split(/\n+/)
// const data = (await readFile('./input-short.txt')).split(/\n+/)
global.console.log('input length:', data.length)

function filterByIthBit(bitstring, i, value) {
  return bitstring.slice(i, i+1) === value
}

function calculateFrequencies(input, nthBit) {
  return input.reduce((acc, row) => {
    if (!(row?.length)) return acc
    const bit = row.slice(nthBit, nthBit + 1)
    return {
      '0': bit === '0' ? acc['0']+1 : acc['0'],
      '1': bit === '1' ? acc['1']+1 : acc['1'],
    }
  }, {'0': 0, '1': 0})
} // TODO new implementation: partition the input by first-char, then let calling fn decide what to do with larger list

function filterByMostCommonBit(data, bit) {
  if (data?.length === 1) return data
  const bitFrequency = calculateFrequencies(data, bit)
  return data.filter(row => filterByIthBit(row, bit, bitFrequency['0'] > bitFrequency['1'] ? '0' : '1'))
}

function filterByLeastCommonBit(data, bit) {
  if (data?.length === 1) return data
  const bitFrequency = calculateFrequencies(data, bit)
  return data.filter(row => filterByIthBit(row, bit, bitFrequency['0'] < bitFrequency['1'] ? '0' : '1'))
}

function oxygen(data) {
  const inputRecordLength = data?.[0]?.length
  let dataset = data
  for (
    let bit = 0;
    bit < inputRecordLength;
    bit++
  ) {
    dataset = filterByMostCommonBit(dataset, bit)
  }
  return dataset
}

function carbondioxide(data) {
  const inputRecordLength = data?.[0]?.length
  let dataset = data
  for (
    let bit = 0;
    bit < inputRecordLength;
    bit++
  ) {
    dataset = filterByLeastCommonBit(dataset, bit)
  }
  return dataset
}

const oTwo = parseInt(oxygen(data), 2),
  coTwo = parseInt(carbondioxide(data), 2)

global.console.log({'O2': oTwo, 'CO2': coTwo, rating: oTwo * coTwo})
