#!/usr/bin/env node

import {readFileSync} from 'fs'

const matrix = (await readFileSync('input.txt', 'utf-8'))
  .split(/\r?\n/)
  .map(line => !!line && line.split(''))
  .filter(a => !!a)
;

class T {
  #value; #parent; #left; #right;
  constructor(x, y, r, parent=null) {
    this.#value = `(${x}x${y}@${r})`;
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
  if (!isLineBelowValid && !isNextCharValid) { // are we at the last route??
    if (!lowestRoutes.length) {
      lowestRoutes = [{r,t:new T(x, y, r, parent)}]
    } else {
      const [firstLowest] = lowestRoutes;
      if (r < firstLowest.r) {
        lowestRoutes = [{r,t:new T(x, y, r, parent)}];
        process.stdout.write('\nlowest: '+r)
      } else if (r == firstLowest.r) {
        lowestRoutes.push({r,t:new T(x, y, r, parent)});
        process.stdout.write('.');
      }
    }
  } else { // not at the last route...
    if (isLineBelowValid && x in matrix[y1])
      buildT({x,    y:y1, r:r+Number(matrix[y1]?.[x])}, t)
    if (isNextCharValid)
      buildT({x:x1, y,    r:r+Number(matrix[y][x1])}, t)
  }
}

buildT({x:0,y:0});
process.stdout.write('\n');

console.log('done...', lowestRoutes.length, 'routes...  r:', lowestRoutes[0].r);//, lowestRoute.ancestry())
console.log(lowestRoutes[0].t.ancestry().join('—'))
