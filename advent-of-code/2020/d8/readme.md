# آتاری

زهرا که در طول ترم حسابی درس خوانده، برای تفریح و تازه کردن روح و روان خود تصمیم میگیرد 
به تنهایی پا به جنگ بگذارد.

اون که بسیار ماجراجو است، سعی میکند به مناطق تاریک جنگل که کمتر کسی جرئت رفتن به آنجا دارد برود.

در میانه راه، چشمش به یک دستگاه آتاری میخورد.
پس بررسی متوجه میشود که این آتاری حداقل 60 سال قدمت دارد.

سعی میکند آن را روشن کند ولی از شانس بد او، 
موقع روشن شدن، دستگاه در 
Loading ...
گیر میکند.


اگر شما به جای او بودید، احتمالا دستگاه را دور می انداختید، ولی ا  که یک 
Geek
است، دستگاه را در کوله پشتی اش میگذارد تا
در خانه آتاری را باز کرده و  
BIOS
آن را دیباگ کند.

زهرا به کد های زیر در 
BIOS
آتاری برمیخورد:
```ruby
nop
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6
```

آنطور که به نظر میرسد، این یک کد اسمبلی خاص است که:

- `nop` (No OPeration): هیچکاری نمیکند
- `acc n` (ACCumulate): تنها متغیر در برنامه را به اندازه n اضافه میکند
- `jmp n`: دستور به بالا یا پایین حرکت میکند `n` 

**توجه:**
مقدار متغیر آتاری هنگام روشن شدن برابر 
`0`
است


برای مثال، کد های اسمبلی بالا به این ترتیب اجرا میشوند:
```ruby
nop +0  | 1
acc +1  | 2, 8(!)
jmp +4  | 3
acc +3  | 6
jmp -3  | 7
acc -99 |
acc +1  | 4
jmp -4  | 5
acc +6  |
```

#### 1. `nop`  اول کار، دستور
کاری انجام نمیدهد و به بعد بعد میرود.

#### 2. `acc +1`
 در خط بعد به متغیر مقدار 
`1`
اضافه میشود.

#### 3. `jmp +4`
بعد 4 دستور به پایین جهش میکند

#### 4. `acc +1`
دیگری اجرا شده و به متغیر یکی اضافه میکند.
مقدار متغیر الان
`2` 
است.

#### 5. `jmp +4`


#### 6. `acc +1`

#### 7. `jmp -4`

#### 8. `acc +3`

#### 9. `jmp -3`

اینجا برتامه توی ی حلقه بینهایت گیر افتاده.
به این نتیجه میرسیم که احتمالا به شرایط آب و هوایی، احتمالا یکی از دستور ها توی 
BIOS
عوض شده.

زهرا حدس میزند که احتمالا یکی از 

After some careful analysis, you believe that exactly one instruction is corrupted.

The program is supposed to terminate by attempting to execute an instruction immediately after the last instruction in the file. By changing exactly one jmp or nop, you can repair the boot code and make it terminate correctly.

For example, consider the same program from above:

nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6

If you change the first instruction from nop +0 to jmp +0, it would create a single-instruction infinite loop, never leaving that instruction. If you change almost any of the jmp instructions, the program will still eventually find another jmp instruction and loop forever.

However, if you change the second-to-last instruction (from jmp -4 to nop -4), the program terminates! The instructions are visited in this order:

nop +0  | 1
acc +1  | 2
jmp +4  | 3
acc +3  |
jmp -3  |
acc -99 |
acc +1  | 4
nop -4  | 5
acc +6  | 6
After the last instruction (acc +6), the program terminates by attempting to run the instruction below the last instruction in the file. With this change, after the program terminates, the accumulator contains the value 8 (acc +1, acc +1, acc +6).

Fix the program so that it terminates normally by changing exactly one jmp (to nop) or nop (to jmp). What is the value of the accumulator after the program terminates?

Your puzzle answer was 662.

Both parts of this puzzle are complete! They provide two gold stars: **

At this point, you should return to your Advent calendar and try another puzzle.

If you still want to see it, you can get your puzzle input.
