import {readFile} from '../helpers.file.mjs'

const data = (await readFile('./input.txt')).split(/\n+/)

const result = data.reduce(({aim, depth, horiz}, command) => {
  const [direction, valueStr] = command.split(' ')
  const value = Number(valueStr)
  switch (direction) {
    case 'forward':
      return {
        aim,
        depth: depth + (aim * value),
        horiz: horiz + value,
      }
    case 'down':
      return {
        aim: aim + value,
        depth,
        horiz,
      }
    case 'up':
      return {
        aim: aim - value,
        depth,
        horiz,
      }
    default:
      throw new Error(`unexpected direction: "${direction}"`)
  }
}, {
  aim: 0,
  horiz: 0,
  depth: 0,
})

global.console.log(result, result.horiz * result.depth)
