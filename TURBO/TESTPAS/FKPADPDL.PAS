var key: byte;
    kar: char;
begin

   writeln('press function keys to test them or press ESC to stop test');
   kar:=#32;
   while kar <> #27 do
   begin
      key:=getfkey;
      if key > 0 then
         writeln('function key ',key,' pressed');

      read(kbd,kar);
   end;

   kar:=#32;
   while kar <> #27 do
   begin
      write(getpad(12):4);
      write(getpad(13):4);
      writeln(getpad(14):4);
      if keypressed then read(kbd,kar);
   end;

   while keypressed do read(kbd,kar);
end.

