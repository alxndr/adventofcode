import {readFile} from '../helpers.file.mjs'

const data = (await readFile('./input.txt')).split(/\n/)

let draws = data[0].split(',')

/*
 * data structure for boards...
 * [
 *   [
 *     {num: #, isCalled: Boolean},
 *     {num: #, isCalled: Boolean},
 *     ...
 *   ],
 *   ...
 * ]
 */

// could pre-generate the winning sequences for each board...

function spaces(n) {
  return Array(n).fill(' ').join('')
}
function leftPad(str, length) {
  if (str.length < length) {
    return `${spaces(length - str.length)}${str}`
  }
  return str
}

function BingoSquare(num) {
  let isCalled = false
  return {
    get asString() {
      return leftPad(`${isCalled ? '(' : ''}${num}${isCalled ? ')' : ''}`, 5)
    },
    isCalled,
    num,
  }
}

const rowAsString = (row) => row.map(square => square.asString).join('')

function Board(boardRows, name) {
  let isWinner = false
  let winningNumber = 0 // only winners have score?
  const numbers = []
  const rows = boardRows.map((row) => {
    return row.split(/ +/).map(numString => {
      const num = Number(numString)
      const square = new BingoSquare(num)
      numbers[num] = square
      return square
    })
  })
  function didWeWin(drawnNumber) {
    for (let i = 0; !isWinner && i < rows.length; i++) {
      if (rows[i].every(square => square.isCalled)) {
        isWinner = true
        winningNumber = drawnNumber
        break
      }
      if (rows.every(row => row[i].isCalled)) {
        isWinner = true
        winningNumber = drawnNumber
        break
      }
    }
    return isWinner
  }
  function mark(numStr) { // returns true if we won
    const num = Number(numStr)
    if (numbers[num]) {
      numbers[num].isCalled = true
      return didWeWin(num) // will also set `this.isWinner` if we've won
    }
    return false
  }
  return {
    get asString() {
      return `
      Board ${name}
${rows.map(row => rowAsString(row)).join('\n')}
      `
    },
    isWinner,
    mark,
    name,
    get score() { return numbers.filter(number => !number.isCalled).map(number => number.num).reduce((a, b) => a + b) * winningNumber }
  }
}

function extractBoards(rows) {
  let boardCount = 0
  let boards = []
  let boardRows = []
  rows.forEach(row => {
    if (row === '') { // empty line is the input separator between different boards
      boards.push(new Board(boardRows, ++boardCount))
      boardRows = []
    } else {
      boardRows.push(row.trim())
    }
  })
  boards.push(new Board(boardRows, 'last')) // special-case to create the last board
  return boards
}

let boards = extractBoards(data.slice(2))
let lastWinner

let limiter = 200
while (limiter-->0 && boards.length) {
  const nextDraw = draws.shift()
  if (nextDraw) {
    global.console.log('drawing...', nextDraw)
    if (boards.length === 1) {
      const isWinner = boards[0].mark(nextDraw)
      if (isWinner) {
        lastWinner = boards.pop()
        global.console.log('last winner!')
        global.console.log(lastWinner.score)
      }
    } else {
      boards = boards.filter(board => {
        const isWinner = board.mark(nextDraw)
        if (isWinner) {
          global.console.log('Winner!')
          global.console.log(board.asString)
        }
        return !isWinner
      })
    }
  }
}

global.console.log(lastWinner.asString)
