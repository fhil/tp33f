var Channel,Scr: INTEGER;
    kar: char;
begin
   clrscr;
   for Scr:=0 to 15 do
   begin
      ClrScr;
      for Channel:=0 to 15 do
      begin
         write('PSG reg.: ',ReadPSG(Channel):3);
         write(' VDP status: ',ReadStatus(Channel):3);
         writeln(' VDP reg.: ',ReadVDP(Channel):3);
      end;
   end;

   while not keypressed do
   begin
      if strig(0) then
      begin
         writeln('space key pressed');
         if keypressed then read(kbd,kar);
      end;
      if strig(1) then writeln('controller 1, button 1 pressed');
      if strig(2) then writeln('controller 2, button 1 pressed');
      if strig(3) then writeln('controller 1, button 2 pressed');
      if strig(4) then writeln('controller 2, button 2 pressed');
   end;
end.