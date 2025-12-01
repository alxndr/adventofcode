import fs from 'fs'
import {expect, test} from 'bun:test'

function* inputChar(input) { // this probably does not need to be a generator...
  const trimmedInput = input.trim()
  const inputLength = trimmedInput.length
  for (let i = 0; i < inputLength; i++)
    yield {i, digit: Number(trimmedInput[i])}
}

class FileBlock {
  length
  location
  id
  constructor(length, id) {
    this.id = id
    this.length = length
  }
  setLocation(l) {
    this.location = l
  }
  isFreeSpace() {
    return false
  }
  toString() {
    return Array(this.length).fill(this.id).join('')
  }
  inspect() {
    return `File(${this.length}) #${this.id} @${this.location}`
  }
}
class FreeBlock {
  length
  location
  id = 'FREE'
  constructor(length) {
    this.length = length
  }
  setLocation(l) {
    this.location = l
  }
  isFreeSpace() {
    return true
  }
  toString() {
    return Array(this.length).fill('.').join('')
  }
  inspect() {
    return `Free(${this.length}) @${this.location}`
  }
}

function blocksToString(blocks) {
  return blocks.reduce((str, block) => {
    return str + block.toString()
  }, '')
}

function diskmapToArray(str) {
  const blocks = Array()
  let fileId = 0
  for (const {i, digit} of inputChar(str)) {
    if (i % 2) {
      blocks.push(new FreeBlock(digit))
    } else {
      blocks.push(new FileBlock(digit, fileId++))
    }
  }
  return blocks
}

function sumConsecutive(a, b) {
  return ((a + b) * (b - a + 1)) / 2
}

function calculateChecksum(blocks) {
  return blocks.reduce(({checksum, index}, block) => {
    if (block.isFreeSpace())
      throw new Error('ruh roh, should be no free spaces when calculating checksum')
    return {
      checksum: checksum + block.id * sumConsecutive(index, index + block.length - 1),
      index: index + block.length}
  }, {checksum: 0, index: 0}).checksum
}

function blockIsFreeSpace(block) {
  return block.isFreeSpace()
}

function doDefrag(blocks) {
  // console.log(blocks.map(b => b.toString()).join(''))
  const blocksLength = blocks.length
  const lastBlock = blocks[blocksLength - 1]
  if (lastBlock.isFreeSpace())
    return doDefrag(blocks.slice(0, blocksLength - 1))
  // lastBlock is a file...
  const nextFreeSpaceIndex = blocks.findIndex(blockIsFreeSpace)
  if (nextFreeSpaceIndex === -1)
    return blocks
  const nextFreeBlock = blocks[nextFreeSpaceIndex]
  if (nextFreeBlock.length === lastBlock.length) {
    return doDefrag(
      blocks.slice(0, nextFreeSpaceIndex)
        .concat(lastBlock, blocks.slice(nextFreeSpaceIndex + 1, blocksLength - 1)))
  } else if (nextFreeBlock.length > lastBlock.length) {
    nextFreeBlock.length -= lastBlock.length
    return doDefrag(
      blocks.slice(0, nextFreeSpaceIndex)
        .concat(
          lastBlock,
          nextFreeBlock,
          blocks.slice(nextFreeSpaceIndex + 1, blocksLength - 1)))
  } else {
    const partOfLastBlock = new FileBlock(nextFreeBlock.length, lastBlock.id)
    lastBlock.length -= nextFreeBlock.length
    return doDefrag(
      blocks.slice(0, nextFreeSpaceIndex)
      .concat(
        partOfLastBlock,
        blocks.slice(nextFreeSpaceIndex + 1, blocksLength - 1),
        lastBlock))
  }
}

function part1(input) {
  const blocks = diskmapToArray(input)
  const defragged = doDefrag(blocks)
  return calculateChecksum(defragged)
}

function doDefragPart2(fraggedBlocks) {
  // "Attempt to move each file exactly once in order of decreasing file ID number starting with the file with the highest file ID number"
  // it does not say what to do about two files with equal ID numbers...
  // ...we don't want to scan through the list of blocks every iteration to find the highest ID.
  // this implies converting it into a dict of ID: block[] where each block also stores its location?
  let defraggedBlocks = [...fraggedBlocks]
  const blocksDict = fraggedBlocks.reduce((dict, b, index) => {
    const id = b.id
    if (!dict[id]) dict[id] = []
    b.setLocation(index) // this is block index, not index within unfraggedBlocks...
    dict[id].push(b)
    return dict
  }, {})
  // console.log(blocksDict)
  const freeBlocks = blocksDict['FREE']
  // console.log('free:', freeBlocks.map(fb => fb.inspect()))
  Object.keys(blocksDict).toSorted().toReversed().forEach(key => {
    if (key === 'FREE') return // only moving file blocks...
    console.log(`\nKey ${key} has ${blocksDict[key].length} files...`)
    blocksDict[key].toReversed().forEach(blockForId => {
      const fileBlockLength = blockForId.length
      const firstFreeSpaceIndex = freeBlocks.findIndex(fb => fb.length >= fileBlockLength)
      if (firstFreeSpaceIndex === -1) { // this one can't go anywhere
        console.log('cant move:', blockForId.inspect())
        return
      }
      console.log(blocksToString(defraggedBlocks))
      console.log(blockForId.inspect(), '... could fit @', freeBlocks[firstFreeSpaceIndex].inspect())
      if (freeBlocks[firstFreeSpaceIndex].length === fileBlockLength) {
        defraggedBlocks = defraggedBlocks.slice(0, freeBlocks[firstFreeSpaceIndex].location)
          .concat(
            blockForId,
            defraggedBlocks.slice(freeBlocks[firstFreeSpaceIndex].location + 1, blockForId.location),
            defraggedBlocks.slice(blockForId.location + 1),
          )
        delete freeBlocks[firstFreeSpaceIndex]
      } else {
        const theFreeBlock = freeBlocks[firstFreeSpaceIndex]
        theFreeBlock.length -= blockForId.length
        // TODO why is teh block of `777` not being removed from its old place?
        // TODO also gotta replace the old location with free space.......
        defraggedBlocks = defraggedBlocks.slice(0, freeBlocks[firstFreeSpaceIndex].location)
          .concat(
            blockForId,
            freeBlocks[firstFreeSpaceIndex],
            defraggedBlocks.slice(freeBlocks[firstFreeSpaceIndex].location + 1, blockForId.location),
            defraggedBlocks.slice(blockForId.location + 1),
          )
        // the remaining free block and all ones following it need to have their locations increased...
        for (let i = firstFreeSpaceIndex; i < freeBlocks.length; i++) {
          freeBlocks[i].location += 1
        }
      }
      console.log(blocksToString(defraggedBlocks))
    })
  })
  return blocksToString(defraggedBlocks)
}

test('sumConsecutive', () => {
  expect(sumConsecutive(2, 4)).toEqual(2 + 3 + 4)
  expect(sumConsecutive(3, 7)).toEqual(3 + 4 + 5 + 6 + 7)
})

const sampleInput = fs.readFileSync('./sample.txt', 'utf8')
const fullInput = fs.readFileSync('./input.txt', 'utf8')

test('part 1', () => {
  expect(blocksToString([new FileBlock(1,0)])).toEqual('0')
  expect(blocksToString([new FileBlock(1,0), new FreeBlock(2), new FileBlock(3,1)])).toEqual('0..111')
  expect(blocksToString(
    diskmapToArray('12345')
  )).toEqual('0..111....22222')
  expect(blocksToString(
    doDefrag([
      new FileBlock(2,0),
      new FreeBlock(5),
      new FileBlock(3,1)
    ])
  )).toEqual('00111')
  expect(blocksToString(
    doDefrag(diskmapToArray('12345'))
  )).toEqual('022111222')
  expect(calculateChecksum(doDefrag(diskmapToArray('12345')))).toEqual(60)
  expect(part1('12345')).toEqual(60)
  expect(part1(sampleInput)).toEqual(1928)
  expect(part1(fullInput)).toEqual(6283170117911)
})

function part2(input) {
  const blocks = diskmapToArray(input)
  const defragged = doDefragPart2(blocks)
  return defragged
}

test('part 2', () => {
  expect(part2(sampleInput)).toEqual(2858)
})
