
{$I-,R-,A-}
program test;

type longarray = array[0..3] of byte;

type OP_TYPES = ( OP_SUB,
		  OP_ADD,
		  OP_ABS,
		  OP_NEG,
		  OP_NOT,
		  OP_OR,
		  OP_SHL,
		  OP_SHR,
		  OP_MUL,
		  OP_MOD,
		  OP_DIV,
		  OP_AND,
		  OP_EQUAL,
		  OP_NOT_EQUAL,
		  OP_LESS_EQUAL,
		  OP_GREATER_EQUAL,
		  OP_LESS,
		  OP_GREATER,
		  OP_THE_END );
    INFO = RECORD
	      Name: STRING[5];
	      Count: BYTE;
	   END;

VAR OP_INFO: ARRAY[OP_SUB .. OP_THE_END] OF INFO =
	    ( ( 'SUB', 2 ),
	     ( 'ADD', 2 ),
	     ( 'ABS', 1 ),
	     ( 'NEG', 1,
	     ( 'NOT', 1,
	     ( 'OR', 2,
	      'SHL', 2,
	      'SHR', 2,
	      'MUL', 2,
	      'MOD', 2,
	      'DIV', 2,
	      'AND', 2,
	      '=', 2,
	      '<>', 2,
	      '<=', 2,
	      '>=', 2,
	      '<', 2,
	      '>', 2,
	      'EXIT', 0 );

{
var i,j: integer;
    k: longint;

begin
   k:=longint (0);

   i:=$12345678;
   i:=0.0;

   val('1234 ',i,j);
   writeln(i);
   writeln(j);
end.
}

var f: file;

    make: boolean;
    PrintOutput: BOOLEAN;

    i1: longarray;
    j1: longarray;
    r1: longarray;

    byte1, byte2:	 byte;
    int1,  int2:	 integer;
    long1, long2,result: longint;
    real1, real2:	 real;

    i: integer;
    operation: integer;
    op_text: string[5];
    OP_CUR: OP_TYPES;

    fpos: integer;
    fbuf: array[0..127] of byte;

PROCEDURE Operand_Info( OP_TYPE: OP_TYPES );
BEGIN
   IF NOT PrintOutput THEN
      EXIT;

   CASE OP_TYPE OF
      OP_SUB:		WRITE('SUB');
      OP_ADD:		WRITE('ADD');
      OP_ABS:		WRITE('ABS');
      OP_NEG:		WRITE('NEG');
      OP_NOT:		WRITE('NOT');
      OP_OR:		WRITE('OR');
      OP_SHL:		WRITE('SHL');
      OP_SHR:		WRITE('SHR');
      OP_MUL:		WRITE('*');
      OP_MOD:		WRITE('MOD');
      OP_DIV:		WRITE('DIV');
      OP_AND:		WRITE('AND');
      OP_EQUAL: 	WRITE('=');
      OP_NOT_EQUAL:	WRITE('<>');
      OP_LESS_EQUAL:	WRITE('<=');
      OP_GREATER_EQUAL: WRITE('>=');
      OP_LESS:		WRITE('<');
      OP_GREATER:	WRITE('>');
      OP_THE_END:	WRITE('The End');

      ELSE
			WRITE('Unknown');
   END;
END;

PROCEDURE Do_Operation( Long1, Long2: LONGINT;
			Result: LONGINT;
			OP_TYPE: OP_TYPES );
BEGIN

   CASE OP_TYPE OF
      OP_SUB:		Result := Long1 - Long2
      OP_ADD:		WRITE('ADD');
      OP_ABS:		WRITE('ABS');
      OP_NEG:		WRITE('NEG');
      OP_NOT:		WRITE('NOT');
      OP_OR:		WRITE('OR');
      OP_SHL:		WRITE('SHL');
      OP_SHR:		WRITE('SHR');
      OP_MUL:		WRITE('*');
      OP_MOD:		WRITE('MOD');
      OP_DIV:		WRITE('DIV');
      OP_AND:		WRITE('AND');
      OP_EQUAL: 	WRITE('==');
      OP_NOT_EQUAL:	WRITE('<>');
      OP_LESS_EQUAL:	WRITE('<=');
      OP_GREATER_EQUAL: WRITE('>=');
      OP_LESS:		WRITE('<');
      OP_GREATER:	WRITE('>');
      OP_THE_END:	WRITE('The End');

      ELSE
			WRITE('Unknown');
   END;
END;

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

procedure putlong(var f: file; long: longint);
var fconv: longarray absolute long;
begin
   fbuf[fpos]  := fconv[0];
   fbuf[fpos+1]:= fconv[1];
   fbuf[fpos+2]:= fconv[2];
   fbuf[fpos+3]:= fconv[3];

   fpos:=fpos+4;

   if fpos=128 then
   begin
      blockwrite(f,fbuf,1);
      fpos:=0;
   end;
end;

function getlong(var f: file): longint;
var long: longint;
    fconv: longarray absolute long;
begin
   fconv[0]:=fbuf[fpos];
   fconv[1]:=fbuf[fpos+1];
   fconv[2]:=fbuf[fpos+2];
   fconv[3]:=fbuf[fpos+3];

   fpos:=fpos+4;

   if fpos=128 then
   begin
      blockread(f,fbuf,1);
      fpos:=0;
   end;
   getlong:=long;
end;

procedure flushlong(var f: file);
begin
   putlong(f,-1);

   if fpos>0 then
   begin
      blockwrite(f,fbuf,1);
      fpos:=0;
   end;
end;

function compare_long(long1: longint): boolean;
var lconv1: longarray absolute long1;
    long2: longint;
    lconv2: longarray absolute long2;
begin
   if make then
   begin
      putlong(f,long1);
      long2:=long1;
   end
   else
   begin
      long2:=getlong(f);
   end;

   IF PrintOutput THEN
   BEGIN
      hexlong(long2);
      write(' ');
   END;

   if (lconv1[0]<>lconv2[0]) or (lconv1[1]<>lconv2[1]) or
      (lconv1[2]<>lconv2[2]) or (lconv1[3]<>lconv2[3]) then

      IF PrintOutput THEN
	 WRITE('err')

   else

      IF PrintOutput THEN
	 WRITE(' OK');
end;

procedure generate_long(var long: longint);
var fconv: longarray absolute long;
begin
   if make then
   begin
      fconv[0]:=random(256);
      fconv[1]:=random(256);
      fconv[2]:=random(256);
      fconv[3]:=random(256);
      putlong(f,long);
   end else long:=getlong(f);
end;

procedure generate_operators(var long1,long2: longint);
begin
   generate_long(long1);
   generate_long(long2);
end;

procedure var_test(long1,long2: longint);
var result: longint;
begin

end;

{
function to_float(a: longarray): real;
var temp: real;
begin
   if a[3] > 127 then
      temp:=-(a[0]+256.0*a[1]+65536.0*a[2]+16777216.0*(a[3] and $7f))
   else
      temp:= (a[0]+256.0*a[1]+65536.0*a[2]+16777216.0*(a[3] and $7f));

   to_float:=temp;
end;

function realtolong(a: real): real;
begin
   if (a > 2147483647.0) then
      a:=a-4294967296.0;

   realtolong:=a;
end;

procedure printlongarray(a: longarray);
begin
   write(a[0]:4,a[1]:4,a[2]:4,a[3]:4,' ');
end;
}

begin

   make:=false;

   assign(f,'long.dat');
   {$i-}
   reset(f);
   if ioresult<>0 then
   begin
      if make then rewrite(f)
      else
      begin
	 writeln('error opening ''long.dat''');
	 halt;
      end;
   end;
   {$i+}

   if make then
   begin
      fpos:=0;
   end
   else
   begin
      fpos:=128-4;
      long1:=getlong(f);
   end;
   writeln;

   OP_CUR := OP_SUB;

   WHILE OP_CUR <> OP_THE_END DO
   BEGIN
      I:=0;
      WHILE I < 22 DO
      BEGIN
	 Generate_Operators(Long1, Long2);

	 
      END;

      OP_CUR = SUCC(OP_CUR);
   END;

   writeln('            op 1 hex,op 2 hex   ',
	   '   sub byt   int        real');

   for i:=1 to 22 do
   begin
      generate_operators(long1,long2);

      result:=long1 - long2; compare_long(result);

      byte1:=long1;		{ assign: long naar byte }
      int1:=long1;		{ assign: long naar integer }
      real1:=long1;		{ assign: long naar real }

      hexlong(long1); write(',');
      hexlong(long2); write(' ');
      hexlong(result);
      writeln;
   end;
   readln;

   writeln('            op 1 hex,op 2 hex   ',
	   '   add byt   int        real');
   for i:=1 to 22 do
   begin
      generate_operators(long1,long2);

      result:=long1 + long2; compare_long(result);

      byte1:=long1;		{ assign: long naar byte }
      int1:=long1;		{ assign: long naar integer }
      real1:=long1;		{ assign: long naar real }

      hexlong(long1); write(',');
      hexlong(long2); write(' ');
      hexlong(result);
      writeln;
   end;
   readln;

   writeln('            op 1 hex,op 2 hex   ',
	   '   abs byt   int        real');
   for i:=1 to 22 do
   begin
      long2:=0;
      generate_long(long1);

      result:=abs(long1); compare_long(result);

      byte1:=long1;		{ assign: long naar byte }
      int1:=long1;		{ assign: long naar integer }
      real1:=long1;		{ assign: long naar real }

      hexlong(long1); write(',');
      hexlong(long2); write(' ');
      hexlong(result);
      writeln;
   end;
   readln;

   writeln('            op 1 hex,op 2 hex   ',
	   '   neg byt   int        real');
   for i:=1 to 22 do
   begin
      long2:=0;
      generate_long(long1);

      result:=-long1; compare_long(result);

      byte1:=long1;		{ assign: long naar byte }
      int1:=long1;		{ assign: long naar integer }
      real1:=long1;		{ assign: long naar real }

      hexlong(long1); write(',');
      hexlong(long2); write(' ');
      hexlong(result);
      writeln;
   end;
   readln;

   writeln('            op 1 hex,op 2 hex   ',
	   '   not byt   int        real');
   for i:=1 to 22 do
   begin
      long2:=0;
      generate_long(long1);

      result:=not long1; compare_long(result);

      byte1:=long1;		{ assign: long naar byte }
      int1:=long1;		{ assign: long naar integer }
      real1:=long1;		{ assign: long naar real }

      hexlong(long1); write(',');
      hexlong(long2); write(' ');
      hexlong(result);
      writeln;
   end;
   readln;

   writeln('            op 1 hex,op 2 hex   ',
	   '   xor byt   int        real');
   for i:=1 to 22 do
   begin
      generate_operators(long1,long2);

      result:=long1 xor long2; compare_long(result);

      byte1:=long1;		{ assign: long naar byte }
      int1:=long1;		{ assign: long naar integer }
      real1:=long1;		{ assign: long naar real }

      hexlong(long1); write(',');
      hexlong(long2); write(' ');
      hexlong(result);
      writeln;
   end;
   readln;

   writeln('            op 1 hex,op 2 hex   ',
	   '    or byt   int        real');
   for i:=1 to 22 do
   begin
      generate_operators(long1,long2);

      result:=long1 or long2; compare_long(result);

      byte1:=long1;		{ assign: long naar byte }
      int1:=long1;		{ assign: long naar integer }
      real1:=long1;		{ assign: long naar real }

      hexlong(long1); write(',');
      hexlong(long2); write(' ');
      hexlong(result);
      writeln;
   end;
   readln;

   writeln('            op 1 hex,op 2 hex   ',
	   '   shl byt   int        real');
   for i:=1 to 22 do
   begin
      generate_long(long1);

      if make then
      begin
	 long2:=random(32);
	 putlong(f,long2)
      end
      else long2:=getlong(f);

      result:=long1 shl long2; compare_long(result);

      byte1:=long1;		{ assign: long naar byte }
      int1:=long1;		{ assign: long naar integer }
      real1:=long1;		{ assign: long naar real }

      hexlong(long1); write(',');
      hexlong(long2); write(' ');
      hexlong(result);
      writeln;
   end;
   readln;

   writeln('            op 1 hex,op 2 hex   ',
	   '   shr byt   int        real');
   for i:=1 to 22 do
   begin
      generate_long(long1);

      if make then
      begin
	 long2:=random(32);
	 putlong(f,long2)
      end
      else long2:=getlong(f);

      result:=long1 shr long2; compare_long(result);

      byte1:=long1;		{ assign: long naar byte }
      int1:=long1;		{ assign: long naar integer }
      real1:=long1;		{ assign: long naar real }

      hexlong(long1); write(',');
      hexlong(long2); write(' ');
      hexlong(result);
      writeln;
   end;
   readln;

   writeln('            op 1 hex,op 2 hex',
	   ' multiply byt   int        real');
   for i:=1 to 22 do
   begin
      generate_operators(long1,long2);

      result:=long1 * long2; compare_long(result);

      byte1:=long1;		{ assign: long naar byte }
      int1:=long1;		{ assign: long naar integer }
      real1:=long1;		{ assign: long naar real }

      hexlong(long1); write(',');
      hexlong(long2); write(' ');
      hexlong(result);
      writeln;
   end;
   readln;

   writeln('            op 1 hex,op 2 hex   ',
	   'modulo byt   int        real');
   for i:=1 to 22 do
   begin
      generate_operators(long1,long2);

      result:=long1 mod long2; compare_long(result);

      byte1:=long1;		{ assign: long naar byte }
      int1:=long1;		{ assign: long naar integer }
      real1:=long1;		{ assign: long naar real }

      hexlong(long1); write(',');
      hexlong(long2); write(' ');
      hexlong(result);
      writeln;
   end;
   readln;

   writeln('            op 1 hex,op 2 hex   ',
	   'divide byt   int        real');
   for i:=1 to 22 do
   begin
      generate_operators(long1,long2);

      result:=long1 div long2; compare_long(result);

      byte1:=long1;		{ assign: long naar byte }
      int1:=long1;		{ assign: long naar integer }
      real1:=long1;		{ assign: long naar real }

      hexlong(long1); write(',');
      hexlong(long2); write(' ');
      hexlong(result);
      writeln;
   end;
   readln;

   writeln('            op 1 hex,op 2 hex   ',
	   '   and byt   int        real');
   for i:=1 to 22 do
   begin
      generate_operators(long1,long2);

      result:=long1 and long2; compare_long(result);

      byte1:=long1;		{ assign: long naar byte }
      int1:=long1;		{ assign: long naar integer }
      real1:=long1;		{ assign: long naar real }

      hexlong(long1); write(',');
      hexlong(long2); write(' ');
      hexlong(result);
      writeln;
   end;
   readln;

   writeln('Equal');
   for i:=1 to 22 do
   begin
      generate_operators(long1,long2);
      result:=ord(long1=long2); compare_long(result);

      hexlong(long1); write(','); hexlong(long2);
      write(' ');
      writeln(long1=long2);
   end;
   readln;


   writeln('Non Equal');
   for i:=1 to 22 do
   begin
      generate_operators(long1,long2);
      result:=ord(long1<>long2); compare_long(result);

      hexlong(long1); write(','); hexlong(long2);
      write(' ');
      writeln(long1<>long2);
   end;
   readln;

   writeln('Less Equal');
   for i:=1 to 22 do
   begin
      generate_operators(long1,long2);
      result:=ord(long1<=long2); compare_long(result);

      hexlong(long1); write(','); hexlong(long2);
      write(' ');
      writeln(long1<=long2);
   end;
   readln;

   writeln('Greater Equal');
   for i:=1 to 22 do
   begin
      generate_operators(long1,long2);
      result:=ord(long1>=long2); compare_long(result);

      hexlong(long1); write(','); hexlong(long2);
      write(' ');
      writeln(long1>=long2);
   end;
   readln;

   writeln('Less');
   for i:=1 to 22 do
   begin
      generate_operators(long1,long2);
      result:=ord(long1<long2); compare_long(result);

      hexlong(long1); write(','); hexlong(long2);
      write(' ');
      writeln(long1<long2);
   end;
   readln;

   writeln('Greater');
   for i:=1 to 22 do
   begin
      generate_operators(long1,long2);
      result:=ord(long1>long2); compare_long(result);

      hexlong(long1); write(','); hexlong(long2);
      write(' ');
      writeln(long1>long2);
   end;
   readln;

   flushlong(f);

   close(f);
   writeln(fpos);
end.
