import {readFile} from '../helpers.file.mjs'

const data = (await readFile('./input.txt')).split(/\n+/)

const result = data.reduce((pos, command) => {
  const [direction, distanceStr] = command.split(' ')
  const distance = Number(distanceStr)
  switch (direction) {
    case 'forward':
      return {
        ...pos,
        horiz: pos.horiz + distance,
      }
    case 'down':
      return {
        ...pos,
        depth: pos.depth + distance,
      }
    case 'up':
      return {
        ...pos,
        depth: pos.depth - distance,
      }
    default:
      throw new Error(`unexpected direction: "${direction}"`)
  }
}, {
  horiz: 0,
  depth: 0,
})

global.console.log(result, result.horiz * result.depth)
