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

function lookForReflectionRow(matrix: string[]): number|false {
  // log('\n\nlookForReflectionRow beginning of call')
  // log(matrix.join('\n'))
  let startingRow = 0;
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

function lookForHorizontalSymmetry(matrix) {
  // log('rotating............')
  const rotated = rotateR(matrix)
  const horizSymmCol = lookForReflectionRow(rotated)
  return horizSymmCol === false
    ? 0
    : 1 + horizSymmCol
}
function lookForVerticalSymmetry(matrix) {
  const verticalSymmetryRow = lookForReflectionRow(matrix)
  return verticalSymmetryRow === false
    ? 0
    : 1 + verticalSymmetryRow
}

function doSomethingWithEachMatrix(matrix, idx) {
  log(`\n\nmatrix number ${idx}...`)
  const vertSymmRow = lookForVerticalSymmetry(matrix)
  if (vertSymmRow) {
    log('vertSymmRow:', vertSymmRow, '.... => ', 100 * (vertSymmRow))
    log(formatReflection(matrix, vertSymmRow, 'H'))
    return 100 * (vertSymmRow)
  }
  const horizSymmCol = lookForHorizontalSymmetry(matrix)
  if (horizSymmCol) {
    log('\nhorizSymmCol:', horizSymmCol)
    log(formatReflection(matrix, horizSymmCol, 'V'))
    return horizSymmCol
  }
  return 0;
}

function solvePart1(input: string[]): number {
  return separateFields(input)
    .map(doSomethingWithEachMatrix) // may mutate the input...
    .reduce((a, e) => a + e)
}

function solvePart2(input: string[]): number {
  return null
}

export {
  separateFields,
  findConsecutiveMatchingRows,
  isMatchingRowsRecursive,
  lookForReflectionRow,
  solvePart1,
  solvePart2,
}
