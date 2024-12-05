import fs from 'fs'
import {expect, test} from 'bun:test'

const testInput = fs.readFileSync('./sample.txt', 'utf8')
const fullInput = fs.readFileSync('./input.txt', 'utf8')

function part1(input) {
  const {rulespecs, updates} = processInput(input)
  const correctlyOrderedUpdates = updates.filter(isCorrectlyOrdered({rulespecs, updates}))
  return correctlyOrderedUpdates
    .map(middleNumber)
    .reduce((a, b) => a + b)
}

function part2(input) {
  const {rulespecs, updates} = processInput(input)
  const incorrectlyOrderedUpdates = updates.filter(update => !(isCorrectlyOrdered({rulespecs, updates})(update)))
  const reordered = incorrectlyOrderedUpdates
    .map(incorrectUpdate => {
      return incorrectUpdate.toSorted((a, b) => {
        const rulesA = rulespecs[a]
        if (rulesA.mustComeBefore.includes(b))
          return -1
        if (rulesA.mustComeAfter.includes(b))
          return 1
        return 0
      })
    })
  return reordered
    .map(middleNumber)
    .reduce((a, b) => a + b)
}

function createRulesHash(rules, ruleRaw) {
  const [earlier, later] = ruleRaw.split('|').map(Number)
  if (rules[earlier]) {
    rules[earlier].mustComeBefore.push(later)
  } else {
    rules[earlier] = {mustComeBefore: [later], mustComeAfter: []}
  }
  if (rules[later]) {
    rules[later].mustComeAfter.push(earlier)
  } else {
    rules[later] = {mustComeBefore: [], mustComeAfter: [earlier]}
  }
  return rules
}

function processInput(input) {
  const inputSplit = input.trim().split('\n')
  const blankLineIndex = inputSplit.indexOf('')
  const rulespecs = inputSplit.slice(0, blankLineIndex).reduce(createRulesHash, {})
  const updates = inputSplit.slice(blankLineIndex + 1).map(u => u.split(',').map(Number))
  return {rulespecs, updates}
}

function isCorrectlyOrdered({rulespecs, updates}) {
  return function(update) {
    for (let i = 0; i < update.length; i++) {
      const num = update[i]
      const rulesForThisNumber = rulespecs[num]
      if (!rulesForThisNumber)
        return true // no rules about the number means it's okay
      const prior = update.slice(0, i)
      const following = update.slice(i + 1)
      const {mustComeBefore, mustComeAfter} = rulesForThisNumber
      if (prior.find(priorNum => mustComeBefore.includes(priorNum)))
        return false
      if (following.find(followingNum => mustComeAfter.includes(followingNum)))
        return false
    }
    return true
  }
}

function middleNumber(update) {
  return update[Math.floor(update.length / 2)]
}

test('part 1', () => {
  expect(part1(testInput)).toBe(143)
  expect(part1(fullInput)).toBe(6034)
})

test('part 2', () => {
  expect(part2(testInput)).toBe(123)
  expect(part2(fullInput)).toBe(6305)
})
