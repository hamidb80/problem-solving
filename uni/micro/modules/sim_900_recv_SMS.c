>> AT+CMGF=1  // set the message style to "English" text
              // for "Persian" or "Chinese" should be 0
<< OK

>> AT+CNMI=1,2,0,0,0 // set the listener
<< OK

// dumps newline(\r\n) if haven't received any 
// message for some time ...

// dumps this pattern whenever a SMS arrived
+CMT: "Phone Number","","Date Time"
Message Text 

