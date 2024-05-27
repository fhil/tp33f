var drive: byte;
begin
   writeln('Current drive: ',chr(getdrive+65));

   for drive:=0 to 8 do
   begin
      write('Drive: ',chr(drive+65),': = ');
      if not testdrive(drive) then write('not ');
      writeln('present');
   end;

   writeln(geterror);
end.

