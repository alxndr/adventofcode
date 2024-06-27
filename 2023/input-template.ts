import path from 'path'
import {readFile} from 'fs/promises'

const find = (textFilename:string) => path.join(import.meta.url.replace(new RegExp('^file://'), ''), '..', textFilename)

export const sample = (await readFile(find('sample.txt'), 'utf-8')).trim().split(/\r?\n/)

export const full = (await readFile(find('full.txt'), 'utf-8')).trim().split(/\r?\n/)
