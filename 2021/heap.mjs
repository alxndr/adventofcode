// quotes are from Skiena's "The Algorithm Design Manual" 2nd ed, pp. 109–

// "heapsort is nothing but an implementation of selection sort using the right data structure"
// "heaps ... maintain[] a partial order on the set of elements which is weaker than the sorted order (so it can be efficient to maintain) yet stronger than random order (so the minimum element can be quickly identified)"
// heap-labeled tree: binary tree where a node's key/value "dominates" the children's key/values
// to avoid using a ton of memory for storing pointers, store values in an array as a Heap

function childL(index) {
  return index * 2
}
function childR(index) {
  return index * 2 + 1
}

function Heap(input = []) {
  // "represent binary trees without using any pointers"
  // "store data as an array of keys, and use the position of the keys to implicitly satisfy the role of the pointers"
  // "store the root of the tree in the first position", 2nd pos is left child, 3rd right child
  // "store the 2^i keys of the ith level of a complete binary tree from L-to-R in positions 2^(i-1) to (2^i - 1)"
  const priority_queue = [null] // "array starts with index 1 to simplify matters"
  function bubble_up(index) { // recursive
    if (index === 1) return // at parent/root; stop recursion
    const parent_index = Math.floor(index/2)
    if (priority_queue[parent_index] > priority_queue[index]) {
      swap_values(index, parent_index)
      bubble_up(parent_index)
    }
  }
  function insert(value) {
    priority_queue.push(value)
    bubble_up(priority_queue.length - 1)
  }
  function swap_values(indexA, indexB) {
    const tempVal = priority_queue[indexA]
    priority_queue[indexA] = priority_queue[indexB]
    priority_queue[indexB] = tempVal
  }
  input.forEach((inputValue) => insert(inputValue))
  return {
    get asString() {return priority_queue.slice(1).join(',')},
    insert,
    remove() {},
  }
}

const h = new Heap([1941, 2001, 1804, 1783, 1865, 1918, 1492, 1945, 1963, 1776])
global.console.log(h.asString)
