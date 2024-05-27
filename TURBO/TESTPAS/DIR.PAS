type str63=string[63];
var attribute: byte;
    b,infoblock: str63;
    name: str63;
begin
   writeln(tsrpresent('fh gios 2.1'));
   attribute:=0;
   if (findfirst('*.*',infoblock,attribute,name)) then
   begin
      writeln(name,#9,attribute);

      while (findnext(infoblock,attribute,name)) do
      begin
         writeln(name,#9,attribute);
      end;
   end;
   writeln('eof dir');
end.