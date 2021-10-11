unit PORTUtil;

interface


uses Windows;
// Port COM
Procedure DELAY(i:WORD); stdcall; external 'PORT.DLL';

Procedure DELAYUS(i:DWORD); stdcall; external 'PORT.DLL';

Function OPENCOM(S:PCHAR):Integer;stdcall; external 'PORT.DLL';

Procedure CLOSECOM();stdcall; external 'PORT.DLL';

Function READBYTE:Integer;stdcall; external 'PORT.DLL';

Procedure SENDBYTE(d:WORD);stdcall; external 'PORT.DLL';

Procedure DTR(d:WORD);stdcall; external 'PORT.DLL';

Procedure RTS(d:WORD);stdcall; external 'PORT.DLL';

Procedure TXD(d:WORD);stdcall; external 'PORT.DLL';

Function CTS:Integer;stdcall; external 'PORT.DLL';

Function DSR:Integer;stdcall; external 'PORT.DLL';

Function RI:Integer;stdcall; external 'PORT.DLL';

Function DCD:Integer;stdcall; external 'PORT.DLL';

implementation

end.

