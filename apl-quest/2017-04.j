NB. remove inside quotes
NB. thanks to https://code.jsoftware.com/wiki/APL2JPhraseBook

n =: 'this "is" a "test"'
i =: '"' = n
n #~ -. i +: -. 2 | +/\ i