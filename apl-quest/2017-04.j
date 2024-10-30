NB. remove inside quotes

n =: 'this "is" a "test"'
i =: '"' = n
n #~ -. i +: -. 2 | +/\ i