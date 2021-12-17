import {readFile} from '../helpers.file.mjs'
const input = (await readFile('./input.txt')).split(/\n/)

const GREEN = '\x1b[32m'
const RESET = '\x1b[0m'

function formatGarden(garden) {
  return garden.map(row =>
    row.map(n => n === 0 ? `${GREEN}0${RESET}` : n).join('')
  ).join('\n')
}

let octopusGarden = input.map(line => line.split('').map(Number))
global.console.log('starting point...')
global.console.log(formatGarden(octopusGarden))

function matrixMap(matrix, callback) {
  return matrix.map(row => row.map(callback))
}

const LIMIT = 9

function flash(garden) {
  if (!garden.find(row => row.find(octopus => octopus > LIMIT))) {
    // if none of the octos are > LIMIT, return garden
    return garden
  }
  garden.forEach((row, indexY) => row.forEach((octopus, indexX) => { // can mutate `garden`
    if (octopus > LIMIT) {
      // flashing...
      // only increment neighbor if it exists and it's non-zero (as zeroes have just flashed within this step)
      if (garden[indexY-1]) {
        garden[indexY-1][indexX-1] && garden[indexY-1][indexX-1] <= LIMIT && garden[indexY-1][indexX-1]++
        garden[indexY-1][indexX  ] && garden[indexY-1][indexX  ] <= LIMIT && garden[indexY-1][indexX  ]++
        garden[indexY-1][indexX+1] && garden[indexY-1][indexX+1] <= LIMIT && garden[indexY-1][indexX+1]++
      }
      garden[indexY][indexX-1] && garden[indexY][indexX-1] <= LIMIT && garden[indexY][indexX-1]++
      garden[indexY][indexX] = 0
      garden[indexY][indexX+1] && garden[indexY][indexX+1] <= LIMIT && garden[indexY][indexX+1]++
      if (garden[indexY+1]) {
        garden[indexY+1][indexX-1] && garden[indexY+1][indexX-1] <= LIMIT && garden[indexY+1][indexX-1]++
        garden[indexY+1][indexX  ] && garden[indexY+1][indexX  ] <= LIMIT && garden[indexY+1][indexX  ]++
        garden[indexY+1][indexX+1] && garden[indexY+1][indexX+1] <= LIMIT && garden[indexY+1][indexX+1]++
      }
    }
  }))
  return flash(garden)
}

function step(garden) {
  // "First, the energy level of each octopus increases by 1."
  const increasedEnergy = matrixMap(garden, (octopus) => ++octopus) // garden.map(row => row.map(octopus => ++octopus))
  // "Then, any octopus with an energy level greater than 9 flashes. This increases the energy level of all adjacent octopuses by 1, including octopuses that are diagonally adjacent."
  // "If this causes an octopus to have an energy level greater than 9, it also flashes."
  // "This process continues as long as new octopuses keep having their energy level increased beyond 9."
  // "(An octopus can only flash at most once per step.)"
  return flash(increasedEnergy)
}

// import {createInterface} from 'readline'

// const stdin = createInterface({input: process.stdin})

const flashes = []

for (let i = 0; i < 100; i++) {
  octopusGarden = step(octopusGarden)
  flashes.push(octopusGarden.map(row => row.filter(n => n === 0).length).reduce((a, b) => a + b))
  // global.console.log({step: flashes.length, sum: flashes.reduce((a, b) => a + b)}, flashes)
  // global.console.log(formatGarden(octopusGarden))
}
global.console.log({step: flashes.length, sum: flashes.reduce((a, b) => a + b)}, flashes)
global.console.log(formatGarden(octopusGarden))
