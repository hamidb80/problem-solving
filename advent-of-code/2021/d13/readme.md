# اریگامی آدم فضایی ها

حسن شب پرخوری کرده و در خواب عجیبی است.
او خواب میبیند به مخفی گاه موجودات فضایی بد نفوذ کرده،
و به دنبال سر نخی از خراب کاری های آنان است.

اون کاغذ شفاف (طلق) ای را پیدا میکند که کنار آن 
لیستی از جفت عدد هایی نوشته شده اند که با ویرگول (,) جدا شده اند.

```
6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0
```

بنابر تجربه حسن حدس میزند که شاید این جفت عدد ها، مختصات باشند.

حسن در خواب مسخره خود سعی میکند مختصات هارا روی کاغذ شفاف
( 
  به طوری که بالا سمت چپ نشان دهنده نقطه 0و0
  و جهت مثبت محور افقی به سمت راست 
  و جهت مثبت محور عمودی سمت پایین باشد
)
جایگذاری کند.

(نقاط علامت زده شده با # و نقاط خالی با . نمایش داده شدند)
```
...#..#..#.
....#......
...........
#..........
...#....#.#
...........
...........
...........
...........
...........
.#....#.##.
....#......
......#...#
#..........
#.#........
```

خب قاعدتا تا به اینجا شکل خاصی رو صفحه ایجاد نشده. 
او ورقه دیگری پیدا میکند که دستوراتی روی آن نوشته شده که میگویند باید ورقه را تا کند
```
fold along y=7
fold along x=5
```
دستور اول میگویند که ورقه را در محور
y=7
تا کند.

در شکل زیر، نقاط محور
y=7
با کاراکتر 
`-`
نشان داده شده است:
 ```
...#..#..#.
....#......
...........
#..........
...#....#.#
...........
...........
-----------
...........
...........
.#....#.##.
....#......
......#...#
#..........
#.#........
```

ورقه را تا میکنیم.
 
 قاعدتا نقاط خالی 
( کاراکتر `.` )
وقتی روی هم میتند، همچنان  خالی یا 
`.`
باقی میمانند، در غیر این صورت، تبدیل به نقطه پر 
`#`
میشوند:
```
#.##..#..#.
#...#......
......#...#
#...#......
.#.#..#.###
...........
...........
```
دستور دوم که میگوید ورقه در محور
`x=5`
تا کنیم نیز اجرا میکنیم:

```
#.##.|#..#.
#...#|.....
.....|#...#
#...#|.....
.#.#.|#.###
.....|.....
.....|.....
```
که میشود:
```
#####
#...#
#...#
#...#
#####
.....
.....
```
که در نهایت یک مربع شد!


## وظیفه شما
به شما لیست نقاطی به همراه دستورات تا کردن داده شده، به حسن کمک کنید تا دستورات را رمز گشایی کند.