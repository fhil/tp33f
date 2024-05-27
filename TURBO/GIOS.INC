type str12 = string[12];
     str64 = string[63];
     str255= string[255];

procedure TsrCall(TsrName: str12;
                  A,BC,DE,HL: integer;
                  var resA,resBC,resDE,resHL: integer);
var result: integer;
begin
   result:=0;
   inline($21/TsrName/
          $23/
          $11/$3e/$4d/
          $cd/$ca/$ff/
          $3e/$00/
          $8f/
          $32/result/
          $20/$22/

          $c5/
          $06/$08/
          $11/$32/$4d/
          $cd/$ca/$ff/
          $dd/$e1/
          $e5/
          $fd/$21/*+20/
          $fd/$e3/
          $3a/A/
          $ed/$4b/BC/
          $ed/$5b/DE/
          $2a/HL/
          $fd/$e9/

          $32/A/
          $ed/$43/BC/
          $ed/$53/DE/
          $22/HL
          );
   resA:=A;
   resBC:=BC;
   resDE:=DE;
   resHL:=HL;
end;

PROCEDURE LoadGifPicture(DoelX,DoelY,Breedte,Hoogte: INTEGER;
                         var position: REAL;
                         FileName: STR64); EXTERNAL $F9CD;
PROCEDURE DefGifSize(OffsetX,OffsetY,
                     GifSizeX,GifSizeY,
                     ScreenWidth,ScreenHeight,
                     Condition: INTEGER); EXTERNAL $F9CE;
PROCEDURE DefGif2(VRAMaddress: INTEGER;
                  InterlacedFormat: BOOLEAN;
                  CodeSize: BYTE); EXTERNAL $F9CF;

PROCEDURE FWrite(VAR woord : str255); EXTERNAL $F99A;

procedure CheckEnv;
var i: integer;
begin
   if (not MemmanPresent) then
   begin
      writeln('MemMan not present');
      halt;
   end;
   writeln('MemmanVersion: ',MemmanVersion shr 8,MemmanVersion and 15);
   if (MemmanVersion < $204) then
   begin
      writeln('Current MemMan version: ',
              MemManVersion shr 8,'.',MemManVersion and 15);
      writeln('MemMan 2.4 or higher required');
      halt;
   end;
   if (not GIOSPresent) then
   begin
      writeln('GIOS not present');
      halt;
   end;
   if (GIOSVersion < $215) then
   begin
      writeln('Current GIOS Version: ',
              GIOSVersion shr 8,'.',
              (GIOSVersion shr 4) and 15,
              GIOSVersion and 15);
      writeln('GIOS 2.15 or higher required');
      halt;
   end;

   mem[$f975]:=$11; mem[$f976]:=lo(-$f981); mem[$f977]:=hi(-$f981);
   mem[$f978]:=$e1;
   mem[$f979]:=$19;
   mem[$f97a]:=$7d;
   mem[$f97b]:=$2a;
   mem[$f97c]:=lo(addr(RunGIOS));
   mem[$f97d]:=hi(addr(RunGIOS));
   mem[$f97e]:=$e9;

   for i:=$f980 to $f980+100 do mem[i]:=$D7; { RST 10H }
   mem[$10]:=$c3; mem[$11]:=$75; mem[$12]:=$f9;

   ClearMem;
end;
