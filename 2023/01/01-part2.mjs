#!/usr/bin/env node

/* edge cases! e.g.:
 - 1nineight
 - fiveight
*/

import {readFileSync} from 'fs'
const input = (await readFileSync('input.txt', 'utf-8')).split(/\r?\n/)
// const input = (await readFileSync('2sample.txt', 'utf-8')).split(/\r?\n/)
if (!input[input.length-1].length) input.pop() // trim a POSIX trailing newline

console.log('...01 part 2')//, input)

const ARR_NUMBERWORDS = ['zero', 'one','two','three','four','five','six','seven','eight','nine'];
const ARR_NUMBERWORDS_BACKWARDS = ['orez', 'eno', 'owt', 'eerht', 'ruof', 'evif', 'xis', 'neves', 'thgie', 'enin']
const REGEX_NUMBERWORDS = new RegExp(`(${ARR_NUMBERWORDS.join('|')})`)
const REGEX_NUMBERWORDS_BACKWARDS = new RegExp(`(${ARR_NUMBERWORDS_BACKWARDS.join('|')})`)
const REGEX_NUMBERWORDS_OR_INTS = new RegExp(`(\\d|${ARR_NUMBERWORDS.join('|')})`)
const REGEX_NUMBERWORDS_BACKWARDS_OR_INTS = new RegExp(`(\\d|${ARR_NUMBERWORDS.join('|').split('').reverse().join('')})`)

console.log('final sum:',
  input.reduce((sum, s) => {
    const sBackwards = s.split('').reverse().join('')
    const m = sBackwards.match(REGEX_NUMBERWORDS_BACKWARDS_OR_INTS)
    const a = Number(s.match(REGEX_NUMBERWORDS_OR_INTS)?.[0].replace(REGEX_NUMBERWORDS, numStr => ARR_NUMBERWORDS.indexOf(numStr)))
    const b = Number(m[0].replace(REGEX_NUMBERWORDS_BACKWARDS, numStr => ARR_NUMBERWORDS_BACKWARDS.indexOf(numStr)))
    global.console.log({sum, a, b, inc:(10 * a) + Number(b)})
    return sum + (10 * a) + Number(b)
  }, 0)
)
