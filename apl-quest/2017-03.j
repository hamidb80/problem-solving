NB. remove inside quotes
NB. thanks to https://code.jsoftware.com/wiki/APL2JPhraseBook

missQuoted =. 3 : 0
  i =: y = '"'
  y #~ -. i +: -. 2 | +/\ i
)

missQuoted 'this "is" a test'
