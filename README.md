# apl.nvim

This is a neovim plugin for GNU APL - an (almost) complete implementation of ISO standard 13751

WIP. Feel free to contribute.
See `./test/some.apl`

This plugin is based heavily on [SCNvim](scnvim) by David Granström.

## some default mappings
|-------|-----------------------------|
| C-e   | (evaluate __line/block__)   |
| A-e   | (evaluate __line__)         |
| Enter | (toggle interpreter window) |
|-------|-----------------------------|

## new block evaluation
`⍝►` ... `⍝◄`

```
⍝►
(g h j) ← 30 51 23
words←'END'
('satan' 'novra' 'flot' 'hund')
chars←'abcdefghijklmnopqr..'
style←'∥⍙⍠≢≡⌷⌸⍤⍢⍰⍥⍞⍬⌹⊖⍉⌽'  ⍝ attitude skatter
tri←,chars∘.,chars∘.,chars∘.,style
{⍺,' <:> ',⍵}⌿tri[5?≢tri]
{⍺,' ○⎕○ ',⍵}⌿words[2?≢words]
6?123
(?512*('asn' ∘.= 'ananas'))-1
{(+⌿⍵)÷≢⍵} 1.1 g h j
halvPi←○1÷2
halvPi+2
⍝◄
```
