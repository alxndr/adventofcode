import {createInterface} from 'readline/promises';
import {setTimeout} from 'timers/promises'

const IS_DEBUGGING = Boolean(process.env.IS_DEBUGGING) || false
const IS_PRINTING_OUTPUT = Boolean(process.env.IS_PRINTING_OUTPUT) || false

export function inputToMatrix(input:string):Array<Array<string>> {
  return input.split('\n').map(str => str.split(''))
}

enum Direction {
  Up = 'U',
  Down = 'D',
  Left = 'L',
  Right = 'R'
}

class Photon {
  x: number;
  y: number;
  dir: Direction;
  constructor(x:number, y:number, dir:Direction) {
    this.x = x;
    this.y = y;
    this.dir = dir;
  }
}

class Contraption {
  grid: string[][];
  private gridHeight: number;
  private gridWidth: number;
  private photons: Photon[];
  energizedTiles: Direction[][][];
  constructor(input:string) {
    this.grid = inputToMatrix(input)
    this.gridHeight = this.grid.length
    this.gridWidth = this.grid[0].length
    this.energizedTiles = new Array(this.gridHeight).fill(null).map(_ => new Array(this.gridWidth).fill(null).map(_ => []))
    this.photons = [new Photon(-1, 0, Direction.Right)]
  }
  tick():void {
    // console.log('tick...')
    this.photons = this.photons.reduce((ps:Photon[], p) => {
      // console.log({count:ps.length, p})
      const isInitialPhoton = (p.x === -1 && p.y === 0)
      if (!isInitialPhoton && this.energizedTiles[p.y][p.x].includes(p.dir))
        return ps // no need to retread
      if (!isInitialPhoton)
        this.energizedTiles[p.y][p.x].push(p.dir)
      const nextLocationY = p.dir === Direction.Up ? p.y - 1 : p.dir === Direction.Down ? p.y + 1 : p.y;
      if (nextLocationY < 0 || nextLocationY >= this.gridHeight)
        return ps
      const nextLocationX = p.dir === Direction.Left ? p.x - 1 : p.dir === Direction.Right ? p.x + 1 : p.x
      if (nextLocationX < 0 || nextLocationX >= this.gridWidth)
        return ps
      const nextLocationTile = this.grid[nextLocationY][nextLocationX]
      // console.log({nextLocationX, nextLocationY, nextLocationTile})
      switch (nextLocationTile) {
        case '/': {
          switch (p.dir) {
            case Direction.Right: {
              if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Up)) {
                ps.push(new Photon(nextLocationX, nextLocationY, Direction.Up))
              }
              return ps
            }
            case Direction.Left: {
              if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Down)) {
                ps.push(new Photon(nextLocationX, nextLocationY, Direction.Down))
              }
              return ps
            }
            case Direction.Up: {
              if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Right)) {
                ps.push(new Photon(nextLocationX, nextLocationY, Direction.Right))
              }
              return ps
            }
            case Direction.Down: {
              if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Left)) {
                ps.push(new Photon(nextLocationX, nextLocationY, Direction.Left))
              }
              return ps
            }
          }
        }
        case '\\': {
          switch (p.dir) {
            case Direction.Right: {
              if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Down)) {
                ps.push(new Photon(nextLocationX, nextLocationY, Direction.Down))
              }
              return ps
            }
            case Direction.Left: {
              if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Up)) {
                ps.push(new Photon(nextLocationX, nextLocationY, Direction.Up))
              }
              return ps
            }
            case Direction.Up: {
              if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Left)) {
                ps.push(new Photon(nextLocationX, nextLocationY, Direction.Left))
              }
              return ps
            }
            case Direction.Down: {
              if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Right)) {
                ps.push(new Photon(nextLocationX, nextLocationY, Direction.Right))
              }
              return ps
            }
          }
        }
        case '-': {
          if (p.dir === Direction.Up || p.dir === Direction.Down) {
            if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Left)) {
              ps.push(new Photon(nextLocationX, nextLocationY, Direction.Left))
            }
            if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Left)) {
              ps.push(new Photon(nextLocationX, nextLocationY, Direction.Right))
            }
          } else {
            if (!this.energizedTiles[nextLocationY][nextLocationX].includes(p.dir)) {
              ps.push(new Photon(nextLocationX, nextLocationY, p.dir))
            }
          }
          return ps
        }
        case '|': {
          if (p.dir === Direction.Left || p.dir === Direction.Right) {
            if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Up)) {
              ps.push(new Photon(nextLocationX, nextLocationY, Direction.Up))
            }
            if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Down)) {
              ps.push(new Photon(nextLocationX, nextLocationY, Direction.Down))
            }
          } else {
            if (!this.energizedTiles[nextLocationY][nextLocationX].includes(p.dir)) {
              ps.push(new Photon(nextLocationX, nextLocationY, p.dir))
            }
          }
          return ps
        }
        default:
          return ps.concat(new Photon(nextLocationX, nextLocationY, p.dir))
      }
    }, []).flat()
    // console.log('after a tick, here is the photons array', this.photons)
  }
  countEnergizedTiles():number {
    // console.log('-----\n' + this.toString() + '------')
    return this.energizedTiles.reduce((count, line) => count + line.filter(l => l.length).length, 0)
  }
  numPhotons():number {
    return this.photons.length
  }
  toString():string {
    let str = ''
    for (let y = 0; y < this.gridHeight; y++) {
      for (let x = 0; x < this.gridWidth; x++) {
        const numDirections = this.energizedTiles[y][x].length
        if (numDirections > 4) throw new Error(`wha happen: ${numDirections} @ (${x},${y})`)
        str += numDirections ? numDirections.toString() : ' '
      }
      str += '\n'
    }
    return str
  }
}

export async function countEnergizedTiles(input:string):Promise<number> {
  const contraption = new Contraption(input)
  while (contraption.numPhotons()) {
    contraption.tick()
    if (IS_PRINTING_OUTPUT) console.log('\n' + contraption.toString())
    if (IS_DEBUGGING) {
      console.log('count energized:', contraption.countEnergizedTiles(), 'num photons:', contraption.numPhotons())
      const rl = createInterface({ input: process.stdin, output: process.stdout });
      await rl.question('...');
      rl.close()
    } else {
      if (IS_PRINTING_OUTPUT) await setTimeout(15)
    }
  }
  return contraption.countEnergizedTiles()
}

class ContraptionPart2 {
  grid: string[][];
  initialPhoton: Photon;
  energizedTiles: Direction[][][];
  private gridHeight: number;
  private gridWidth: number;
  private photons: Photon[];
  constructor(inputMatrix:string[][]) {
    this.grid = inputMatrix
    this.gridHeight = this.grid.length
    this.gridWidth = this.grid[0].length
  }
  determineEnergizedTilesCount(initialPhoton:Photon):number {
    this.initialPhoton = initialPhoton
    this.photons = [initialPhoton]
    this.energizedTiles = new Array(this.gridHeight).fill(null).map(_ => new Array(this.gridWidth).fill(null).map(_ => []))
    while (this.photons.length) {
      this.photons = this.photons.reduce((ps:Photon[], p) => {
        if (p !== this.initialPhoton && this.energizedTiles[p.y][p.x].includes(p.dir))
          return ps // we have already been here in this direction
        if (p !== this.initialPhoton) // otherwise, mark that we have been in this direction
          this.energizedTiles[p.y][p.x].push(p.dir)
        const nextLocationY = p.dir === Direction.Up ? p.y - 1 : p.dir === Direction.Down ? p.y + 1 : p.y;
        if (nextLocationY < 0 || nextLocationY >= this.gridHeight)
          return ps
        const nextLocationX = p.dir === Direction.Left ? p.x - 1 : p.dir === Direction.Right ? p.x + 1 : p.x
        if (nextLocationX < 0 || nextLocationX >= this.gridWidth)
          return ps
        switch (this.grid[nextLocationY][nextLocationX]) {
          case '/': {
            switch (p.dir) {
              case Direction.Right: {
                if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Up)) {
                  ps.push(new Photon(nextLocationX, nextLocationY, Direction.Up))
                }
                return ps
              }
              case Direction.Left: {
                if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Down)) {
                  ps.push(new Photon(nextLocationX, nextLocationY, Direction.Down))
                }
                return ps
              }
              case Direction.Up: {
                if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Right)) {
                  ps.push(new Photon(nextLocationX, nextLocationY, Direction.Right))
                }
                return ps
              }
              case Direction.Down: {
                if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Left)) {
                  ps.push(new Photon(nextLocationX, nextLocationY, Direction.Left))
                }
                return ps
              }
            }
          }
          case '\\': {
            switch (p.dir) {
              case Direction.Right: {
                if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Down)) {
                  ps.push(new Photon(nextLocationX, nextLocationY, Direction.Down))
                }
                return ps
              }
              case Direction.Left: {
                if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Up)) {
                  ps.push(new Photon(nextLocationX, nextLocationY, Direction.Up))
                }
                return ps
              }
              case Direction.Up: {
                if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Left)) {
                  ps.push(new Photon(nextLocationX, nextLocationY, Direction.Left))
                }
                return ps
              }
              case Direction.Down: {
                if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Right)) {
                  ps.push(new Photon(nextLocationX, nextLocationY, Direction.Right))
                }
                return ps
              }
            }
          }
          case '-': {
            if (p.dir === Direction.Up || p.dir === Direction.Down) {
              if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Left)) {
                ps.push(new Photon(nextLocationX, nextLocationY, Direction.Left))
              }
              if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Left)) {
                ps.push(new Photon(nextLocationX, nextLocationY, Direction.Right))
              }
            } else {
              if (!this.energizedTiles[nextLocationY][nextLocationX].includes(p.dir)) {
                ps.push(new Photon(nextLocationX, nextLocationY, p.dir))
              }
            }
            return ps
          }
          case '|': {
            if (p.dir === Direction.Left || p.dir === Direction.Right) {
              if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Up)) {
                ps.push(new Photon(nextLocationX, nextLocationY, Direction.Up))
              }
              if (!this.energizedTiles[nextLocationY][nextLocationX].includes(Direction.Down)) {
                ps.push(new Photon(nextLocationX, nextLocationY, Direction.Down))
              }
            } else {
              if (!this.energizedTiles[nextLocationY][nextLocationX].includes(p.dir)) {
                ps.push(new Photon(nextLocationX, nextLocationY, p.dir))
              }
            }
            return ps
          }
          default:
            return ps.concat(new Photon(nextLocationX, nextLocationY, p.dir))
        }
      }, []).flat()
    }
    return this.energizedTiles.reduce((count, line) => count + line.filter(l => l.length).length, 0)
  }
}

export function countMostEnergizedTiles(input:string):number {
  const inputMatrix = inputToMatrix(input)
  const inputHeight = inputMatrix.length
  const inputWidth = inputMatrix[0].length
  const contraption = new ContraptionPart2(inputMatrix)
  let largestCountOfEnergizedTiles = 0
  for (let y = 0; y < inputHeight; y++) {
    const energizedTilesCountRightwards = contraption.determineEnergizedTilesCount(new Photon(-1, y, Direction.Right))
    if (energizedTilesCountRightwards > largestCountOfEnergizedTiles)
      largestCountOfEnergizedTiles = energizedTilesCountRightwards
    const energizedTilesCountLeftwards = contraption.determineEnergizedTilesCount(new Photon(inputWidth, y, Direction.Left))
    if (energizedTilesCountLeftwards > largestCountOfEnergizedTiles)
      largestCountOfEnergizedTiles = energizedTilesCountLeftwards
  }
  for (let x = 0; x < inputWidth; x++) {
    const energizedTilesCountUpwards = contraption.determineEnergizedTilesCount(new Photon(x, inputHeight, Direction.Up))
    if (energizedTilesCountUpwards > largestCountOfEnergizedTiles)
      largestCountOfEnergizedTiles = energizedTilesCountUpwards
    const energizedTilesCountDownwards = contraption.determineEnergizedTilesCount(new Photon(x, -1, Direction.Down))
    if (energizedTilesCountDownwards > largestCountOfEnergizedTiles)
      largestCountOfEnergizedTiles = energizedTilesCountDownwards
  }
  return largestCountOfEnergizedTiles
}
