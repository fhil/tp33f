PROGRAM RunChain;

VAR File1 : FILE;
    Name  : STRING[64];

PROCEDURE LeesParam;
VAR tel : BYTE;
BEGIN
  IF PARAMCOUNT=0 THEN
  BEGIN
    WRITELN('No chain file to run!');
    HALT
  END;
  Name:=ParamStr(1);
  tel:=POS('.',Name);
  IF tel=0 THEN Name:=Name+'.CHN'
           ELSE Name:=COPY(Name,1,tel-1)+'.CHN'
END;

BEGIN
  WRITELN('Chain runner versie 1.0');
  WRITELN;
  LeesParam;
  WRITELN('Loading : ',Name);
  WRITELN('Please wait!');
  WRITELN;
  ASSIGN(File1,Name);
  CHAIN(File1)
END.

