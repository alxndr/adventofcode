import {readFile} from 'fs/promises'

export const inputSample =
`.|...\\....
|.-.\\.....
.....|-...
........|.
..........
.........\\
..../.\\\\..
.-.-/..|..
.|....-|.\\
..//.|....`

export const inputFull = (await readFile('./16/input.txt', 'binary')).trim()
