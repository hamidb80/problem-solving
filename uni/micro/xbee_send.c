// receiver module

>> +++ // enter command mode

>> ATSH     // get higher part of node's address
<< [ADDR_H]

>> ATSL     // get lower part of node's address
<< [ADDR_L]

>> ATCN // exit command mode
<< Transmit Mode // enter Transmit Node

// dumps given data immediately

// sender module ------------------------

>> +++ // enter command mode

>> ATDH [ADDR_H] // set higher part of destination address
<< Write Command successful

>> ATDL [ADDR_L] // set lower part of destination address
<< Write Command successful

>> ATCN // exit command mode
<< Transmit Mode // enter Transmit Node

// put "\r" after your text to send 
// like: Hey I Am Hamid\r
