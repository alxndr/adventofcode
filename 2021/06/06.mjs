import {readFile} from '../helpers.file.mjs'

function Fish(initTimer) {
  this.timer = initTimer
  this.tick = function() {
    if (!this.timer) {
      this.timer = 6
      return true // tack on a new Fish
    }
    --this.timer
  }
}
Fish.prototype.toString = function() { return `Fish:${this.timer}`}

function day(fishes) {
  const newFish = fishes.filter((fish) => fish.tick()).map(() => new Fish(8))
  return fishes.concat(newFish)
}

function days(n, fishes) { // recursive
  if (!n) return fishes
  return days(n - 1, day(fishes))
}

const data = (await readFile('./input.txt')).split(/\n/)[0].split(',')

let fishes = data.map(numStr => new Fish(Number(numStr)))

fishes = days(80, fishes)
global.console.log('how many fishes', fishes.length)
// global.console.log(fishes.map(f => f.toString()))
