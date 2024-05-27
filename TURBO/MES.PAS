program D;
var f: file;
    out: text;
    tab: array[0..2047] of byte;
    low: array[0..31] of integer;
    error: byte;
    i,j,k: integer;
    kar: char;
begin
   assign(f,'turbo.msg');
   reset(f,1);
   blockread(f,tab,1536,i);
   writeln(i);
   close(f);

   assign(out,'output');
   rewrite(out);

   i:=0;
   while tab[i] <> $1a do
   begin
       if tab[i] < $20 then
       begin
	  write(out,'part: ',tab[i]:2,', ');
	  low[tab[i]]:=i+1;
	  i:=i+1;
       end
       else
       begin
	   error:=(tab[i]-48)*10 + (tab[i+1]-48);
	   i:=i+2;
	   write(out,'error: ',error:2,', ');
       end;
       while (tab[i]<>$0d) and (tab[i]<>$1a) do
       begin
	  if tab[i]>=$20 then
	  begin
	     write(out,chr(tab[i]));
	     i:=i+1;
	  end
	  else
	  begin
	     j:=low[tab[i]];
	     i:=i+1;
	     while (tab[j]<>$0d) do
	     begin
		write(out,chr(tab[j]));
		j:=j+1;
	     end;
	  end;
       end;
       writeln(out,'''');
       if tab[i]<>$1a then i:=i+2;
   end;
   close(out);
end.