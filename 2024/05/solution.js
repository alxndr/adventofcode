import fs from 'fs'
import {expect, test} from 'bun:test'

const testInput = fs.readFileSync('./sample.txt', 'utf8')
const fullInput = fs.readFileSync('./input.txt', 'utf8')

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

function part1(input) {
  const inputSplit = input.trim().split('\n')
  const blankLineIndex = inputSplit.indexOf('')
  const rulespecs = inputSplit.slice(0, blankLineIndex).reduce(createRulesHash, {})
  const updates = inputSplit.slice(blankLineIndex + 1).map(u => u.split(',').map(Number))
  const correctlyOrderedUpdates = updates
    .filter(update => {
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
    })
  return correctlyOrderedUpdates
    .map(update => update[Math.floor(update.length / 2)])
    .reduce((a, b) => a + b)
}

test('part 1', () => {
  expect(part1(testInput)).toBe(143)
  expect(part1(fullInput)).toBe(6034)
})
