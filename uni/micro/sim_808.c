...

>> AT+CGPSPWR=1 // make GPS module ready
<< OK

>> AT+CGPSINF=4 // get current GPS location info in $GPGLL format
<< $GPGLL,<Latitude>,<N/S>,<Longitude>,<E/W>,<UTC time>,<Status>,<Mode>,<Checksum>

>> AT+CGPSRST=0 // reset GPS :: cold (for the fist time)
<< OK

>> AT+CGPSRST=1 // reset GPS :: hot
<< OK
