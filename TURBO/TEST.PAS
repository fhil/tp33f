{$A-,W0}

VAR Maximum: INTEGER;

procedure _OverlayProc0_2; forward;

overlay
procedure OverLayProc0_1;
begin
   Maximum:=Maximum+1;

   writeln('Overlay 0--routine 1 ',Maximum);

   if Maximum < 2 then _OverlayProc0_2;

   writeln('Overlay 0, routine 1 ',Maximum);
end;

overlay
procedure OverLayProc0_2;
begin
   Maximum:=Maximum+1;

   writeln('Overlay 0--routine 2 ',Maximum);

   if Maximum < 2 then OverlayProc0_1;

   writeln('Overlay 0, routine 2 ',Maximum);
end;

procedure _OverlayProc0_2;
begin
   OverlayProc0_2;
end;

procedure Dummy_0;
begin
end;

overlay
procedure OverLayProc1_1;
begin
   writeln('Overlay 1, routine 1');
end;

overlay
procedure OverLayProc1_2;
begin
   writeln('Overlay 1, routine 2');
end;

begin
   Maximum:=0;

   OverLayProc0_1;
   OverLayProc0_2;
   OverLayProc0_2;
   OverLayProc0_2;
   OverLayProc0_1;
   OverLayProc0_1;

   OverLayProc1_1;
   OverLayProc1_2;

   { screen(0); }
   writeln(MemManPresent);
   writeln(MemManVersion shr 8,(MemManVersion shr 4) and 15,
	   MemManVersion and 15);
   writeln(GIOSPresent);
   writeln(GIOSVersion shr 8,(GIOSVersion shr 4) and 15,
	   GIOSVersion and 15);
end.

procedure Screen8; inline($3e/$08/$f7/$00/$5f/$00/$c9);

var l: longint;
    i: integer;
begin

   screen8;

   l:=-2147483648;

   writeln(l);

   for i:=-32768 to 32767 do
   begin
      write('.');
   end;
end. 
   asdf
   

   clearmem;
   l:=			set	  
   
   
   mem(4);
   writeln('memory allocated ',l*16384);

   setchannel(0,0);
   memreadfile(0,0,100000.0,'ar1.cmp');

   setchannel(0,0);
   {
   memexpand(0,0,0, 0);
   }

   screen(8);

   for i:=0 to 18 do
      memexpand(0,0,0, 0);

   {
   setchannel(0,4173);
   memexpand(0,0,0, 0);
   }

   screen(0);

   expand(0,0,0, 'turbo.com');
   writeln(geterror);

   writeln(getchannel(0):0:0);

end.

   l:=1048576;

   wri teln('<',l:-10,'>',' <',1048576:10,'>');

   l:=-1;
   writeln('<',longint(-1):-10,'>',' <',longint(-1):10,'>');

   writeln(geterror);
end.

var f: text;
  f  ch: char;

    sect: array[0..511] of byte;

begin
   readsector(0,0,addr(sect),1);
   
   {
   RenameFile('a:\test\gios.inc','a:\test\gios1.inc');
   WRITELN(GetError);
   WRITELN(GetError);
   RenameFile('a:\test\gios1.inc','a:\test\gios.inc');
   WRITELN(GetError);
   WRITELN(GetError);
   }
end.

   assign(f,paramstr(1));
   reset(f);

   while not eof(f) do
   begin
      read(f,ch);
      write(ch);
   end;
end.
