%EVTID==1 is identical to TTL==1000 --> there is a text string
%EVTID==11 --> There is a TTL pulse with a value in TTL; this number is
                %also shown in hexadecimal in the string.
                
                %These values seem to correspond to wire IDs 1-5 in binary
                
                %0  0x0000
                %2  0x0002
                %4  0x0004
                %8  0x0008
                %16  0x0010
                %32  0x0020
                
%0 - switch current state off
%2 - ENDTRIAL
%8 - RIGHTTRIAL (trial start)
%4 - LEFTTRIAL (trial start)
%16 - SUCCESS
%32 - LIGHTON (reward)

%TTL binary Coding scheme changed starting Feb 10, 2020
%->There are more IO ports, but port 3 is limited to [0 2 8 32]

%255 on ports 1&2 and 240 on port 2 initialize a task

%EVTID 1 or TTL 1000 are the secret to decoding codes.