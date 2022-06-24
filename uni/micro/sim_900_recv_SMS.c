>> ATE0              // turn off the Echo of GSM shield.
<< OK

>> AT                // check the module is working fine.
<< OK

>> AT+CMGF = 1       // set the message style to text
<< OK

>> AT+CNMI=1,2,0,0,0 // set the listener
<< OK

// dumps newline(\r\n) if haven't received any 
// message for some time ...

// dumps this pattern whenever a SMS arrived
+CMT: "Phone Number","","Date Time"
Message Text 

