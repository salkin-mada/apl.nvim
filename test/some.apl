⍝ :APLStart

⍝►
)HELP
⍝ ⌈/
⍝◄
⍝►
⊃⎕ARG
)VARS
⎕SYL
⍝◄

⍝►
]KEYB
⍝◄
⍺⌈⌊∆ ⍺_↑?⍴○↓∊?'⌊_⊢⊂⊃∩∪⊥⊤|⍺⌈⌊_∇∆∘'⎕⍎?⍵∊⍴~↑↓⍳○*←→¨¯<≤=≥>≠∨∧×
⌶⍫⍒⍋⌽⍉⊖⍟⍱⍲!⍰⍹⍷⌾⍨↑↓⍸⍥⍣⍞⍬⍶⌈⌊_⍢∆⍤⌸⌷≡≢⊣⊆⊃∩∪⍭⍡∥⍪⍙⍠⊆
⍝►
⍝ )CLEAR
Astro←{0~¨⍨a⌽⊃⌽∊¨0,¨¨!¨a←⌽⍳⍵} 
Astro ?24
  PERSON.firstname ← 'Jane'   ⍝ create variable PERSON with member 'firstname'
  PERSON.lastname  ← 'Doe'    ⍝ add a second member 'lastname' to PERSON
)MORE
⍝◄

⍝►
⎕IO←1
⍳10
⍝◄

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

⍝►
4 ⎕CR """
Noise
Env

Feedback
"""
⍝◄
⍝►
A←3 4⍴1 3 2 0 2 1 0 1 4 0 0 2
B←4 2⍴4 1 0 3 0 2 2 0
Q←{⍺/⍵}
(A≠0) +.Q B
)MORE
⍝◄

⍝►
)FNS
)OPS
)LIBS
⍝ )VALUES ⍝.> All values back in time.. intense
⍝◄
⍝►
]SVARS
⍝◄
⍝►
⎕PLOT ''
)MORE
⍝◄

⍝►
4 ⎕CR 'f..' ⎕RE['g'] '__foo___fun____fox_   fanta lol'
STATE ← 0 ⎕RVAL ''
⍝◄

⍝►
⍝ ?123
STATE ← 0 ⎕RL '' ⍝ the rand generator state
STATE
⍝ 0 ⎕RL STATE ⍝ reset state
⍝◄

⍝►
∇z←⍙⍙⍙class nlf_ni ⍙⍙⍙set
  ⍝ Return a character array of every workspace name which includes
  ⍝ all characters in ⍙⍙⍙set. The empty set matches everything. The
  ⍝ optional ⍙⍙⍙class argument selects results by name class; the
  ⍝ default is 2 3 4 (variables, functions and operators).
  ⍎(0=⎕nc '⍙⍙⍙class')/'⍙⍙⍙class←2 3 4'
  z←⊃{ (∧/⊃(⊂,⍙⍙⍙set)∊¨⍵)/⍵ }{ (∧\' '≠⍵)/⍵ }¨⊂[(1+⎕io)]⎕nl ⍙⍙⍙class
∇
⍝◄

⍝►
)CLASSES
⎕PW
⍝◄

⍝►
(a b _ d) ← 3 1 4 1 ⍝ Don't care about the third value
]USERCMD ]DISPLAY {4 ⎕CR}
]DISPLAY a b d _ ⍝ but its still there, _ is just a convention
((!4)+2)×¯7×○1
V ← (1 4 2 5 (2 4) (5 8)) ⍝ A vector, (matrix) yay
8 ⎕CR V
9 ⎕CR ⍴ V
SIZE ← ?12
'abcdefghijklmnopqrstuvwxyz0123456789'[SIZE SIZE⍴36?36] ⍝ (unique chars)
'abcdefghijklmnopqrstuvwxyz0123456789'[?SIZE SIZE⍴36]   ⍝ (potential repeating chars)
⍝◄
