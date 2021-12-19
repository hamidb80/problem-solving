import intsets, sequtils
import main

let 
  s0 = @[
    newPoint(404,-588,-901),
    newPoint(528,-643,409),
    newPoint(-838,591,734),
    newPoint(390,-675,-793),
    newPoint(-537,-823,-458),
    newPoint(-485,-357,347),
    newPoint(-345,-311,381),
    newPoint(-661,-816,-575),
    newPoint(-876,649,763),
    newPoint(-618,-824,-621),
    newPoint(553,345,-567),
    newPoint(474,580,667),
    newPoint(-447,-329,318),
    newPoint(-584,868,-557),
    newPoint(544,-627,-890),
    newPoint(564,392,-477),
    newPoint(455,729,728),
    newPoint(-892,524,684),
    newPoint(-689,845,-530),
    newPoint(423,-701,434),
    newPoint(7,-33,-71),
    newPoint(630,319,-379),
    newPoint(443,580,662),
    newPoint(-789,900,-551),
    newPoint(459,-707,401),
  ]

  s1 = @[
    newPoint(686,422,578),
    newPoint(605,423,415),
    newPoint(515,917,-361),
    newPoint(-336,658,858),
    newPoint(95,138,22),
    newPoint(-476,619,847),
    newPoint(-340,-569,-846),
    newPoint(567,-361,727),
    newPoint(-460,603,-452),
    newPoint(669,-402,600),
    newPoint(729,430,532),
    newPoint(-500,-761,534),
    newPoint(-322,571,750),
    newPoint(-466,-666,-811),
    newPoint(-429,-592,574),
    newPoint(-355,545,-477),
    newPoint(703,-491,-529),
    newPoint(-328,-685,520),
    newPoint(413,935,-424),
    newPoint(-391,539,-444),
    newPoint(586,-435,557),
    newPoint(-364,-763,-893),
    newPoint(807,-499,-711),
    newPoint(755,-354,-619),
    newPoint(553,889,-390),
  ]


for p1 in s0:
  let n1 = relDistance(p1, s0)
  for p2 in s1:
    let n2 = relDistance(p2, s1)

    echo intersection(n1, n2).len    

echo "--------------"
echo distance2(
  newPoint(0,0,1),
  newPoint(0,0,2)
)