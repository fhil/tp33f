
type longarray = array[0..3] of byte;

function hexdigit(a: byte): char;
begin
   if a<10 then hexdigit:=chr(a+48)
	   else hexdigit:=chr(a+48+7);
end;

procedure hexbyte(a: byte);
begin
   write(hexdigit(a shr 4));
   write(hexdigit(a and 15));
end;

procedure hexword(a: integer);
begin
   hexbyte(a shr 8);
   hexbyte(a and 255);
end;

procedure hexlong(a: longint);
var lconv: longarray absolute a;
begin
   hexbyte(lconv[0]);
   hexbyte(lconv[1]);
   hexbyte(lconv[2]);
   hexbyte(lconv[3]);
end;

VAR i: INTEGER;
    l: LONGINT;
BEGIN

   writeln('PRED INTEGER');
   i:=244;
   writeln('0:       ',pred(0));
   writeln('16:      ',pred(16));
   writeln('-32768:  ',pred(-32768));
   writeln('var(244):',pred(i));
   writeln;

   writeln('PRED LONGINT');
   l:=0;
   writeln('65536:    ',pred(65536));
   writeln('16777216: ',pred(16777216));
   writeln('var(0):   ',pred(l));
   writeln;

   writeln('SUCC INTEGER');
   i:=244;
   writeln('-1:      ',succ(-1));
   writeln('16:      ',succ(16));
   writeln('32767:   ',succ(32767));
   writeln('var(244):',succ(i));
   writeln;

   writeln('SUCC LONGINT');
   l:=-1;
   writeln('-1:      ',succ(-1));
   writeln('16:      ',succ(16));
   writeln('16777215:',succ(16777215),' '); hexlong(succ(16777215));
   writeln('var(-1): ',succ(l));
   writeln;

   writeln('LO INTEGER');
   i:=-1;
   writeln('-1:     ',lo(-1));
   writeln('16:     ',lo(16));
   writeln('4096:   ',lo(4096));
   writeln('32767:  ',lo(32767));
   writeln('var(-1):',lo(i));
   writeln;

   writeln('LO LONGINT');
   l:=$80004004;
   writeln('65537:         ',lo(65537),' '); hexword(lo(65537));
   writeln('var($80004004):',lo(l),' '); hexword(lo(l));
   writeln;

   writeln('HI INTEGER');
   i:=-1;
   writeln('-1:      ',hi(-1),' '); hexword(hi(-1));
   writeln('260:     ',hi(260),' '); hexword(hi(260));
   writeln('4096:    ',hi(4096),' '); hexword(hi(4096));
   writeln('var(-1)  ',hi(-1),' '); hexword(hi(-1));
   writeln;

   writeln('HI LONGINT');
   l:=$80004004;
   writeln('131077:        ',hi(131077),' '); hexword(hi(131077));
   writeln('var($80004004):',hi(l),' '); hexword(hi(l));
   writeln;

   writeln('SWAP INTEGER');
   i:=$8000;
   writeln('16:        ',swap(16),' '); hexword(swap(16));
   writeln('4096:      ',swap(4096),' '); hexword(swap(4096));
   writeln('var($8000):',swap(i),' '); hexword(swap(i));
   writeln;

   writeln('SWAP LONGINT');
   l:=$80004004;
   writeln('131073:       ',swap(131073),' '); hexlong(swap(131073));
   writeln('var($80004004:',swap(l),' '); hexlong(swap(l));
   writeln;

END.
