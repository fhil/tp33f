var a,b,c,d: longint;
    i: integer;
    debug: integer;

procedure binair(a: longint);
var i: integer;
begin
   for i:=0 to 31 do
   begin
      if a<0 then write('1') else write('0');
      a:=a+a;
   end;
   writeln;
end;

function div32(a,b: longint): longint;
var bits: integer;
    bits1: integer;
    c: longint;
begin
   if debug = 1 then
   begin
      write('a: '); binair(a);
      write('b: '); binair(b);
   end;
   if b = 0 then
   begin
      div32:=0;
      exit;
      writeln('divide by zero');
      halt;
   end;
   if a < b then
   begin
      div32:=0;
      exit;
   end;
   bits:=1;
   while a >= b+b do
   begin
      if debug = 1 then
      begin
         write('a: '); binair(a);
         write('b: '); binair(b);
      end;
      b:=b+b;
      bits:=bits+1;
   end;
   if debug = 1 then
   begin
      writeln('bits: ',bits);
      write('b: '); binair(b);
   end;
   c:=0;
   bits1:=bits;
   while bits > 0 do
   begin
      c:=c+c;                   { uitkomst * 2 }
      if debug = 1 then
      begin
         write('a: '); binair(a);
         write('b: '); binair(b);
         write('bits: ',bits);
         readln;
      end;
      if a-b >= 0 then
      begin
         c:=c+1;                { uitkomst + 1 }
         a:=a-b;                { maak aftrekking }
      end;
      a:=a+a;
      bits:=bits-1;
   end;

   if debug = 1 then
   begin
      write('a: '); binair(a);
      write('b: '); binair(b);
      writeln(c);
   end;

   binair(a);
   binair(b);
   write(a shr (bits1),' ',b);
   write('rest: ',(b-a) shr (bits1-1));
   div32:=c;
end;

begin
   debug:=0;

   writeln(div32($e047a117,$f58b4529));

   hexlong($e047a117 mod $f58b4529);
end.

   for i:=0 to 3{ 2767} do
   begin
      a:=(random(3276)+1)*(random(3276)+1);
      a:=32768*32768 - 1;
      b:=(random(32767)+1)*(random(32767)+1);
      {
      write(a:10,b:10); write(c:10);
      }
      if b = 0 then c:=0 else c:=a div b;
      d:=div32(a,b); writeln(' ',a mod b);

      { if (i and 1023 = 0) then write('.'); }
      {
      write(a:10,b:10); write(c:10);
      writeln(d:10);
      }
      if (c <> d) then
      begin
         writeln('foutje');
         halt;
      end;
   end;
end.