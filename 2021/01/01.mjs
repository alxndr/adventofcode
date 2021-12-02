import {createReadStream} from 'fs'

const add = (m, n) => m + n

function sumWindow(arrayOfStrings) {
  return arrayOfStrings.map(Number).reduce(add)
}

function process(data) {
  const processed = data.reduce((accumulator, measurement, index) => { // one iteration
    if (!data[index+2]) return accumulator // we're at the end
    const windowSum = sumWindow([
      measurement,
      data[index+1],
      data[index+2],
    ])
    const processedData = {
      delta: null,
      measurement,
      windowSum,
    }
    if (accumulator[index-1]) { // calculate delta vs prev windowSum
      processedData.delta = windowSum - accumulator[index-1].windowSum
    }
    return accumulator.concat(processedData)
  }, [])
  global.console.log('filtered:', processed.filter(({delta}) => delta > 0).length) // second iteration
  global.console.log('slice', processed.slice(-10))
}

const readableStream = createReadStream('./input.txt')
readableStream.setEncoding('UTF8')
readableStream.on('data', (chunk) => {
  process(chunk.split(/\s+/))
})
readableStream.on('error', (error) => {
  console.debug(error.stack)
  throw error
})
