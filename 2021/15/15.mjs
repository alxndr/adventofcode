#!/usr/bin/env node

import {readFileSync} from 'fs'

const matrix = (await readFileSync('input.txt', 'utf-8'))
  .split(/\r?\n/)
  .map(line => !!line && line.split(''))
  .filter(a => !!a)
;

class T {
  #value; #parent;
  constructor(value, parent=null) {
    this.#value = value
    if (parent !== null) this.#parent = parent;
  }
  ancestry() {
    return (this.#parent?.ancestry() || []).concat(this.#value)
  }
}

let lowestRoutes = [];

function buildT({x, y, r=0}, parent=null) { // recursive... but no return value
  const x1 = x + 1;
  const y1 = y + 1;
  const isLineBelowValid = y1 in matrix;
  const isNextCharValid = x1 in matrix[y];
  const t = new T(`(${x}x${y}@${r})`, parent)
  if (!isLineBelowValid && !isNextCharValid) { // are we at the last route??
    if (r >= 735) return // we know it's under 735...
    const thing = {r, t}
    if (!lowestRoutes.length) {
      lowestRoutes = [thing]
    } else {
      const firstLowestR = lowestRoutes[0].r
      if (r < firstLowestR) {
        lowestRoutes = [thing];
        process.stdout.write('\nlowest: '+r)
      } else if (r == firstLowestR) {
        lowestRoutes.push(thing);
        process.stdout.write('.');
      }
    }
  } else { // not at the last route...
    if (isLineBelowValid && x in matrix[y1])
      buildT({x,    y:y1, r:r+Number(matrix[y1][x])}, t)
    if (isNextCharValid)
      buildT({x:x1, y,    r:r+Number(matrix[y][x1])}, t)
  }
}

buildT({x:0,y:0});
process.stdout.write('\n');

console.log('done...', lowestRoutes.length, 'routes...  r:', lowestRoutes[0].r);
console.log(lowestRoutes[0].t.ancestry().join('—'))
// 735 too high...
