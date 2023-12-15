import {readFileSync} from 'fs'

function readUTF8fileWrapper(filename: string) {
  return async function() {
    return (await readFileSync(filename, 'utf-8')).trim().split(/\r?\n/)
  }
}

const sample = readUTF8fileWrapper('sample.txt')
const full = readUTF8fileWrapper('input.txt')

export {
  full,
  sample,
}
