import {readFile} from '../helpers.file.mjs'
const input = (await readFile('./input.txt')).split(/\n/)

function risk(x, y) {
  if (input[y]?.hasOwnProperty(x))
    return Number(input[y][x]) + 1
  return false
}

const lowPoints = input.reduce((low, inputLine, indexY) => {
  if (!(inputLine?.length)) return low
  inputLine.split('').forEach((n, indexX) => {
    const currentRisk = Number(n) + 1
    const riskL = risk(indexX - 1, indexY)
    const riskU = risk(indexX, indexY - 1)
    const riskR = risk(indexX + 1, indexY)
    const riskD = risk(indexX, indexY + 1)
    if ( (!riskL || riskL > currentRisk)
      && (!riskU || riskU > currentRisk)
      && (!riskR || riskR > currentRisk)
      && (!riskD || riskD > currentRisk)
    ) {
      return low.push({indexX, indexY, risk: currentRisk})
    }
  })
  return low
}, [])

global.console.log({lowPoints, sum: lowPoints.reduce((a, b) => a + b.risk, 0)})
