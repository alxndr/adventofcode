import {readFileSync} from 'fs'

const sample = (await readFileSync('sample.txt', 'utf-8')).split(/\r?\n/)
const full = (await readFileSync('input.txt', 'utf-8')).split(/\r?\n/)

export {
  full,
  sample,
}
