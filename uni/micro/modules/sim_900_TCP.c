// 1. connect to the GPRS service
>> AT+CPIN?
<< +CPIN: READY
<< OK

>> AT+CSQ?
<< +CSQ: 20,0
<< OK

>> AT+CREG?
<< CREG: 0,1
<< OK

>> AT+CGATT?
<< +CGATT: 1
<< OK

// 2. setup GPRS connection 
>> AT+CSTT="CMNET" // set APN to "CMNET"
<< OK

>> AT+CIICR // bring up wireless connection
<< OK

>> AT+CIFSR // get local IP address
<< 10.78.240.51

// 3. connect to the server 
>> AT+CIPSTART="TCP","IP","PORT" // start the connection
<< OK
<< CONNECT OK

>> AT+CIPSEND     // send data 
<< >              // ">" means it's ready to get data
>> [YOUR DATA] \z // you put [YOUR DATA] and then press "\z"
<< SEND OK        // send response

<< hello from server  // if any data recieves from the server, 
                      // it will be dumped immediately

>> AT+CIPCLOSE    // close the connection after you are done
<< CLOSED