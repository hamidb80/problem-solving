// receiver module
>> +++ // enter command mode

>> ATSH
<< [ADDR1]
>> ATSL
<< [ADDR2]

>> ATCN // exit command mode
<< Transmit Mode // enter Transmit Node

// dumps given data immediately

// sender module ------------------------

>> +++ // enter command mode

>> ATDH [ADDR1] // set upper part of destination address
<< Write Command successful

>> ATDL [ADDR2] // set lower part of destination address
<< Write Command successful

>> ATCN // exit command mode
<< Transmit Mode // enter Transmit Node

// send by "\r" like: Hey I Am Hamid\r
