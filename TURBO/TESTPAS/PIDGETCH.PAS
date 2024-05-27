var Channel: INTEGER;
begin
   for Channel:=0 to 15 do
   begin
      writeln(getpageid(Channel):6,getchannel(Channel));
   end;
end.