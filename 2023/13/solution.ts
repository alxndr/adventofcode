const log = console.log.bind(global)

const rotateR = (m) => m[0].split('').map((val, index) => m.map(row => row[index]).reverse().join(''))
const rotateL = (m) => m[0].split('').map((val, index) => m.map(row => row[row.length-1-index]).join(''));

function separateFields(input: string[]) { // TODO explore making this an iterator or generator or whatever
  return input.reduce((aa, row) => {
    if (!row.length) aa.push([])
      else {
        const last = aa.pop()
        last.push(row)
        aa.push(last)
      }
      return aa
  }, [[]])
}

function findConsecutiveMatchingRows(arr, startingRow=0): number {
  // returns -1 if not found...
  // log(`findConsecutiveMatchingRows starting @ ${startingRow} ...`)
  // log(`~~~>${arr.slice(startingRow).join('\n~~~>')}`)
  const slicedArr = arr.slice(startingRow)
  const result = slicedArr.findIndex(
    (elem: string, idx: number) => elem == slicedArr[idx+1]);
  if (result === -1)
    return result
  return startingRow + result
}

function isMatchingRowsRecursive(top: number, bot: number, input: string[], result=true): boolean {
  // log(`isMatchingRowsRecursive?? [${result}] comparing ${top} & ${bot}...`)
  if (!result || top < 0 || bot >= input?.length) {
    // log('BAIL OUT')
    return result
  }
  // log(`${input[top]}`)
  // log(`${input[bot]}  ==>  ${input[top] == input[bot]}`)
  return input[top] == input[bot] &&
    isMatchingRowsRecursive(top-1, bot+1, input, result)
}

function lookForReflectionRow(matrix: string[], sR=0): number|false {
  // log('\n\nlookForReflectionRow beginning of call')
  // log(matrix.join('\n'))
  let startingRow = sR;
  const width = matrix[0].length
  do {
    // log(`lookForReflectionRow... iteration, lookin from ${startingRow}...`)
    const index = findConsecutiveMatchingRows(matrix, startingRow)
    if (index === -1) {
      // log('lookForReflectionRow... no consecutive matching rows! done with this direction...')
      return false
    }
    // log(`lookForReflectionRow... FOUND! ~~>  @ ${index} = ${index+1}`)
    if (isMatchingRowsRecursive(index, index+1, matrix)) return index
    startingRow = index + 1;
    // log(`lookForReflectionRow... not reflective from there... so gonna keep going starting @ ${startingRow} now...`)
  } while (startingRow < matrix.length);
  return false
}

function formatReflection(matrix, where, direction) {
  const width = matrix[0].length
  switch (direction) {
    case 'H':
      return [
        matrix.slice(0,where).join('\n'),
        Array(width).fill('=').join('') + ' ... @ ' + where,
        matrix.slice(where).join('\n')
      ].join('\n')
    case 'V':
      return [
        Array(where-1).fill(' ').join('') + '><' + Array((width - where )-1).fill(' ').join(''),
        ...matrix,
        Array(where-1).fill(' ').join('') + '><' + Array((width - where )-1).fill(' ').join('') + ' @ ' + where,
      ].join('\n')
  }
}

function lookForHorizontalSymmetry(matrix, butNotThis) {
  // log('rotating............')
  const rotated = rotateR(matrix)
  // log('\nrotated!!')
  // log(rotated.join('\n'))
  const horizSymmCol = lookForReflectionRow(rotated, butNotThis)
  return horizSymmCol === false
    ? 0
    : 1 + horizSymmCol
}
function lookForVerticalSymmetry(matrix, butNotThis) {
  const verticalSymmetryRow = lookForReflectionRow(matrix, butNotThis)
  return verticalSymmetryRow === false
    ? 0
    : 1 + verticalSymmetryRow
}

function findSymmetryScore(matrix, butNotThisScore=null) {
  // issue appears to be that while trying to unsmudge...
  // we can have the correct spot to clean, but an earlier symmetry is returned by these lookFor...s
  const vertSymmRow = lookForVerticalSymmetry(matrix, butNotThisScore ? butNotThisScore/100 : null)
  if (vertSymmRow) {
    return 100 * (vertSymmRow)
  }
  const horizSymmCol = lookForHorizontalSymmetry(matrix, butNotThisScore)
  if (horizSymmCol) {
    return horizSymmCol
  }
  return 0;
}

function findValuesForMatrices(input) {
  return separateFields(input)
    .map(findSymmetryScore)
}

function sumItUp(acc, elem) {
  return acc + elem
}
function solvePart1(input: string[]): number {
  return findValuesForMatrices(input)
    .reduce(sumItUp)
}

function alternateCharacter(bit) {
  return bit === '#'
  ? '.'
  : '#'
}
function flipBit(matrix, x, y) {
  // n.b. mutates matrix
  matrix[y] = matrix[y].substring(0,x)
    + alternateCharacter(matrix[y][x])
    + matrix[y].substring(x+1);
}

function findSmudgedSymmetry(matrix, findValue) {
  const iV = findValue()
  const mHeight = matrix.length
  const mWidth = matrix[0].length
  for (let x = 0; x < mWidth; x++) {    // =12
    for (let y = 0; y < mHeight; y++) { // =6
      // if (x == 12 && y == 6) log(`\twas score:${iV} @ (${x} ${y})... `)
      flipBit(matrix, x, y)
      // if (x == 12 && y == 6) log('flip it!!!!! now... ', matrix[y])
      const unsmudgedPossibility = findSymmetryScore(matrix, iV)
      // if (x == 12 && y == 6) log('new val===', unsmudgedPossibility, unsmudgedPossibility && unsmudgedPossibility !== iV, '!!')
      if (unsmudgedPossibility && unsmudgedPossibility !== iV) {
        return unsmudgedPossibility
      }
      flipBit(matrix, x, y) // put it back for next iteration
      // if (x == 12 && y == 6) log('k flipt it back, for next iteration...', matrix[y])
    }
  }
  log('ruh roh nothing found...............\n...........\n........\n.......\n....\n...\n..\n.\n.\n.\n\n\n')
  return 0
}

function solvePart2(input: string[]): number {
  const initialValues = findValuesForMatrices(input)
  return separateFields(input)
    .map((matrix, idx) => {
      // matrix will get mutated...
      log('\n\n\n')
      log(idx)
      log(matrix.join('\n'))
      return findSmudgedSymmetry(matrix, () => initialValues[idx])
    })
    .reduce(sumItUp)
}

export {
  separateFields,
  findConsecutiveMatchingRows,
  isMatchingRowsRecursive,
  lookForReflectionRow,
  solvePart1,
  findSymmetryScore,
  findSmudgedSymmetry,
  solvePart2,
}
