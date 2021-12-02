import {createReadStream} from 'fs'

export function readFile(path) {
  const readableStream = createReadStream(path)
  readableStream.setEncoding('UTF8')
  return new Promise((res, rej) => {
    readableStream.on('data', (chunk) => {
      res(chunk)
    })
    readableStream.on('error', (error) => {
      rej(error)
    })
  })
}
