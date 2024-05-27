PROGRAM CleanUp;                                                  { 20-09-93 }
{
This program "cleans up" the source code of your Turbo-Pascal
applications before printing/uploading. It passes through your
source code twice: once to convert all words (except comments
and strings within WRITE(LN) statements) to lower case and once
again to capitalize the reserved words of Pascal.

Usage requires a "scratch" area on the logged disk of at least
the size of the source file. This will hold the workfile during
the transition between passes of CLEANUP. Please read the note in
the INITKEYS procedure of the casefix section. It will give
you instructions on how to set the global constant "RESERVED"
based on which TURBO version you are using. Also, PLEASE be
patient. the search through the key word array takes time and
may warrant a coffee break.

Thanks go to Bill Cote and J.W. Kindschi, Jr. for their programs
LOWCASE.PAS and TURBFIX.PAS (respectively). These two programs
were combined with some additional code to get to what you
see in this program.

A final note: this program is valid for TURBO version 3.0, and
has been tested on my CPM-80 system. I assume it will work on
MSDOS, CPM86 and others. Please help out with revisions, etc.
and keep me posted.

7/31/85, Doug Pearson [75366,2413]
}

CONST c1 = 135;
      c2 =  15;
      reserved = 244;        { see INITKEYS below for important info on this }

TYPE  NameType  = STRING[14];
      CmdType   = (r,w);
      AlphaType = STRING[c2];

VAR   lptr,wptr,i,j : INTEGER;
      f,g           : TEXT;
      ch            : CHAR;
      line          : STRING[c1];
      found         : BOOLEAN;
      source,dest   : NameType;
      id            : AlphaType;
      key           : ARRAY[1..reserved] OF AlphaType;


FUNCTION Exists(filename : NameType; func : CmdType) : BOOLEAN;
BEGIN
  IF func = r THEN ASSIGN(f,filename)
              ELSE ASSIGN(g,filename);
  {$I-}
  IF func = r THEN RESET(f)
              ELSE REWRITE(g);
  {$I+}
  IF IORESULT <> 0 THEN exists:=FALSE
                   ELSE exists:=TRUE
END;                                                       { -- F. Exists -- }

PROCEDURE LowerCase(VAR Str : AlphaType);
VAR i,x : INTEGER;
BEGIN
  FOR i := 1 TO LENGTH(Str) DO
  IF ((ORD(STR[i])>=65) AND (ORD(STR[i])<=90)) THEN
  BEGIN
    x:=ORD(STR[i]);
    Str[i]:=CHAR(x + $20)
  END
END;                                                  { -- Pr. LowerCase -- }

PROCEDURE LowCase;
BEGIN
  REPEAT
    CLRSCR;
    GOTOXY(1,5);
    WRITELN('This program converts upper to lower case');
    WRITELN('and capitalizes reserved words');
    WRITE('Input File: ');
    READLN(source)
  UNTIL Exists(source,r);
  GOTOXY(1,15);
  CLREOL;
  WRITE('Destination File: ');
  READLN(dest);
  IF Exists('tempfile',w) THEN
  BEGIN
    READLN(f,line);
    WHILE ((NOT EOF(f)) OR (line<>'')) DO
    BEGIN
      IF line<>'' THEN
      BEGIN
        lptr:=1;
        WHILE lptr<=LENGTH(line) DO
        BEGIN
          IF line[lptr]='{' THEN
          BEGIN
            REPEAT
              lptr:=lptr+1;
              IF lptr>LENGTH(line) THEN
              BEGIN
                WRITELN(g,line);
                READLN(f,line);
                lptr:=1
              END;
            UNTIL line[lptr] = '}';
            lptr:= lptr+1
          END;
          IF line[lptr]='''' THEN
          BEGIN
            REPEAT
              lptr:= lptr+1;
            UNTIL line[lptr]='''';
            lptr:=lptr+1
          END;
          IF line[lptr] IN ['A'..'Z'] THEN
          BEGIN
            wptr:=1;
            id:='';
            REPEAT
              id:=CONCAT(id,line[lptr+wptr-1]);
              wptr:=wptr+1;
            UNTIL NOT (line[lptr+wptr-1] IN ['A'..'Z','a'..'z'])
                   OR (lptr+wptr-1 > LENGTH(line));
            lowercase(id);
            DELETE(line,lptr,LENGTH(id));
            INSERT(id,line,lptr);
            lptr:=lptr+wptr;
          END
           ELSE lptr:=lptr+1
        END
      END;
      WRITELN(g,line);
      READLN(f,line)
    END
  END;
  CLOSE(f);
  CLOSE(g)
END;                                                   { -- Pr. LowerCase -- }

PROCEDURE UpperCase(VAR Str : AlphaType);
VAR i: INTEGER;
BEGIN
  FOR i:=1 TO LENGTH(Str) DO Str[i]:=UPCASE(Str[i]);
END;                                                   { -- Pr. UpperCase -- }

PROCEDURE initkeys;
{
The calling program should define one constant and one variable:
RESERVED and KEY.
RESERVED is an integer and should be set to a constant from the
following table:

          If your system is:           RESERVED should be:
               CPM80                         165
               CPM86                         169
               MSDOS (standard)              177
               MSDOS w/ graphics             211
               MSDOS w/ extended graphics    244

KEY should be defined as follows: Var KEY: Array[1..RESERVED] of String[15];
This Procedure can then be called with the statement "Initkeys;".
}
TYPE computers = (cpm80,cpm86,msdos);

VAR  op_system                                  : computers;
     has_graphics,has_extended_graphics,has_bcd : BOOLEAN;
BEGIN
  op_system:=cpm80;
  has_graphics:=FALSE;
  has_extended_graphics:=FALSE;
  has_bcd:=FALSE;
  key[ 1] := 'ABS';          key[ 2] := 'ABSOLUTE';
  key[ 3] := 'ADDR';         key[ 4] := 'AND';
  key[ 5] := 'APPEND';       key[ 6] := 'ARCTAN';
  key[ 7] := 'ARRAY';        key[ 8] := 'ASSIGN';
  key[ 9] := 'AUX';          key[10] := 'AUXINPTR';
  key[11] := 'AUXOUTPTR';    key[12] := 'BEGIN';
  key[13] := 'BLOCKREAD';    key[14] := 'BLOCKWRITE';
  key[15] := 'BOOLEAN';      key[16] := 'BUFLEN';
  key[17] := 'BYTE';         key[18] := 'CASE';
  key[19] := 'CHAIN';        key[20] := 'CHAR';
  key[21] := 'CHR';          key[22] := 'CLOSE';
  key[23] := 'CLREOL';       key[24] := 'CLRSCR';
  key[25] := 'CON';          key[26] := 'CONCAT';
  key[27] := 'CONINPTR';     key[28] := 'CONOUTPTR';
  key[29] := 'CONST';        key[30] := 'CONSTPTR';
  key[31] := 'COPY';         key[32] := 'COS';
  key[33] := 'CRTEXIT';      key[34] := 'CRTINIT';
  key[35] := 'DELAY';        key[36] := 'DELETE';
  key[37] := 'DELLINE';      key[38] := 'DISPOSE';
  key[39] := 'DIV';          key[40] := 'DO';
  key[41] := 'DOWNTO';       key[42] := 'ELSE';
  key[43] := 'END';          key[44] := 'EOF';
  key[45] := 'EOLN';         key[46] := 'ERASE';
  key[47] := 'EXECUTE';      key[48] := 'EXIT';
  key[49] := 'EXP';          key[50] := 'EXTERNAL';
  key[51] := 'FALSE';        key[52] := 'FILE';
  key[53] := 'FILEPOS';      key[54] := 'FILESIZE';
  key[55] := 'FILLCHAR';     key[56] := 'FLUSH';
  key[57] := 'FOR';          key[58] := 'FORWARD';
  key[59] := 'FRAC';         key[60] := 'FREEMEM';
  key[61] := 'FUNCTION';     key[62] := 'GETMEM';
  key[63] := 'GOTO';         key[64] := 'GOTOXY';
  key[65] := 'HALT';         key[66] := 'HEAPPTR';
  key[67] := 'HI';           key[68] := 'IF';
  key[69] := 'IN';           key[70] := 'INLINE';
  key[71] := 'INPUT';        key[72] := 'INSERT';
  key[73] := 'INSLINE';      key[74] := 'INT';
  key[75] := 'INTEGER';      key[76] := 'IORESULT';
  key[77] := 'KBD';          key[78] := 'KEYPRESSED';
  key[79] := 'LABEL';        key[80] := 'LENGTH';
  key[81] := 'LN';           key[82] := 'LO';
  key[83] := 'LOWVIDEO';     key[84] := 'LST';
  key[85] := 'LSTOUTPTR';    key[86] := 'MARK';
  key[87] := 'MAXAVAIL';     key[88] := 'MAXINT';
  key[89] := 'MEM';          key[90] := 'MEMAVAIL';
  key[91] := 'MEMW';         key[92] := 'MOD';
  key[93] := 'MOVE';         key[94] := 'NEW';
  key[95] := 'NIL';          key[96] := 'NORMVIDEO';
  key[97] := 'NOT';          key[98] := 'ODD';
  key[99] := 'OF';           key[100] := 'OR';
  key[101] := 'ORD';         key[102] := 'OUTPUT';
  key[103] := 'OVERLAY';     key[104] := 'PACKED';
  key[105] := 'PARAMCOUNT';  key[106] := 'PARAMSTR';
  key[107] := 'PI';          key[108] := 'PORT';
  key[109] := 'POS';         key[110] := 'PRED';
  key[111] := 'PROCEDURE';   key[112] := 'PROGRAM';
  key[113] := 'PTR';         key[114] := 'RANDOM';
  key[115] := 'RANDOMIZE';   key[116] := 'READ';
  key[117] := 'READLN';      key[118] := 'REAL';
  key[119] := 'RECORD';      key[120] := 'RELEASE';
  key[121] := 'RENAME';      key[122] := 'REPEAT';
  key[123] := 'RESET';       key[124] := 'REWRITE';
  key[125] := 'ROUND';       key[126] := 'SEEK';
  key[127] := 'SEEKEOF';     key[128] := 'SEEKEOLN';
  key[129] := 'SET';         key[130] := 'SHL';
  key[131] := 'SHR';         key[132] := 'SIN';
  key[133] := 'SIZEOF';      key[134] := 'SQR';
  key[135] := 'SQRT';        key[136] := 'STR';
  key[137] := 'STRING';      key[138] := 'SUCC';
  key[139] := 'SWAP';        key[140] := 'TEXT';
  key[141] := 'THEN';        key[142] := 'TO';
  key[143] := 'TRM';         key[144] := 'TRUE';
  key[145] := 'TRUNC';       key[146] := 'TYPE';
  key[147] := 'UNTIL';       key[148] := 'UPCASE';
  key[149] := 'USR';         key[150] := 'USRINPTR';
  key[151] := 'USROUTPTR';   key[152] := 'VAL';
  key[153] := 'VAR';         key[154] := 'WHILE';
  key[155] := 'WITH';        key[156] := 'WRITE';
  key[157] := 'WRITELN';     key[158] := 'XOR';

  CASE op_system OF
    cpm80: BEGIN
             key[159] := 'BDOS';      key[160] := 'BDOSHL';
             key[161] := 'BIOS';      key[162] := 'BIOSHL';
             key[163] := 'OVRDRIVE';  key[164] := 'RECURPTR';
             key[165] := 'STACKPTR';
           END;
    cpm86: BEGIN
             key[159] := 'BDOS';      key[160] := 'BIOS';
             key[161] := 'CSEG';      key[162] := 'DSEG';
             key[163] := 'INTR';      key[164] := 'MEMW';
             key[165] := 'OFS';       key[166] := 'OVRDRIVE';
             key[167] := 'PORTW';     key[168] := 'SEG';
             key[169] := 'SSEG';
           END;
    msdos: BEGIN
             key[159] := 'CHDIR';          key[160] := 'CSEG';
             key[161] := 'DSEG';           key[162] := 'GETDIR';
             key[163] := 'INTR';           key[164] := 'LONGFILEPOS';
             key[165] := 'LONGFILESIZE';   key[166] := 'LONGSEEK';
             key[167] := 'MEMW';           key[168] := 'MKDIR';
             key[169] := 'MSDOS';          key[170] := 'OFS';
             key[171] := 'OVRPATH';        key[172] := 'PORTW';
             key[173] := 'RMDIR';          key[174] := 'SEG';
             key[175] := 'SSEG';           key[176] := 'TRUNCATE';
             key[177] := '';
           END
  END;
  IF ((op_system=msdos) AND (has_graphics)) THEN
  BEGIN
    key[177] := 'BLACK';           key[178] := 'BLINK';
    key[179] := 'BLUE';            key[180] := 'BROWN';
    key[181] := 'CYAN';            key[182] := 'DARKGRAY';
    key[183] := 'DRAW';            key[184] := 'GRAPHBACKGROUND';
    key[185] := 'GRAPHCOLORMODE';  key[186] := 'GRAPHMODE';
    key[187] := 'GRAPHWINDOW';     key[188] := 'GREEN';
    key[189] := 'HIRES';           key[190] := 'HIRESCOLOR';
    key[191] := 'LIGHTBLUE';       key[192] := 'LIGHTCYAN';
    key[193] := 'LIGHTGRAY';       key[194] := 'LIGHTGREEN';
    key[195] := 'LIGHTMAGENTA';    key[196] := 'LIGHTRED';
    key[197] := 'MAGENTA';         key[198] := 'NOSOUND';
    key[199] := 'PALETTE';         key[200] := 'PLOT';
    key[201] := 'RED';             key[202] := 'SOUND';
    key[203] := 'TEXTBACKGROUND';  key[204] := 'TEXTCOLOR';
    key[205] := 'TEXTMODE';        key[206] := 'WHEREX';
    key[207] := 'WHEREY';          key[208] := 'WHITE';
    key[209] := 'WINDOW';          key[210] := 'YELLOW';
    key[211] := '';
    IF has_extended_graphics THEN
    BEGIN
      key[211] := 'ARC';           key[212] := 'BACK';
      key[213] := 'CIRCLE';        key[214] := 'CLEARSCREEN';
      key[215] := 'COLORTABLE';    key[216] := 'EAST';
      key[217] := 'FILLPATTERN';   key[218] := 'FILLSCREEN';
      key[219] := 'FILLSHAPE';     key[220] := 'GETDOTCOLOR';
      key[221] := 'GETPIC';        key[222] := 'HADING';
      key[223] := 'HIDETURTLE';    key[224] := 'HOME';
      key[225] := 'NORTH';         key[226] := 'NOWRAP';
      key[227] := 'PATTERN';       key[228] := 'PENDOWN';
      key[229] := 'PENUP';         key[230] := 'PUTPIC';
      key[231] := 'SETHEADING';    key[232] := 'SETPENCOLOR';
      key[233] := 'SETPOSITION';   key[234] := 'SHOWTURTLE';
      key[235] := 'SOUTH';         key[236] := 'TURNLEFT';
      key[237] := 'TURNRIGHT';     key[238] := 'TURTLETHERE';
      key[239] := 'TURTLEWINDOW';  key[240] := 'WEST';
      key[241] := 'WRAP';          key[242] := 'XCOR';
      key[243] := 'YCOR';          key[244] := '';
    END
  END;
  IF ((op_system=msdos) AND (has_bcd)) THEN key[reserved]:='FORM';
END;                                                    { -- Pr. InitKeys -- }

PROCEDURE CaseFix;
BEGIN
  InitKeys;
  CLRSCR;
  GOTOXY(1,5);
  WRITELN('Now capitalizing');
  GOTOXY(1,23);
  WRITELN('Press any key for a while to quit');
  READLN(f,line);
  WHILE (NOT (EOF(f) OR KEYPRESSED)) OR (line<>'') DO
  BEGIN
    IF line<>'' THEN
    BEGIN
      lptr:=1;
      WHILE lptr<=LENGTH(line) DO
      BEGIN
        IF line[lptr]='{' THEN
        BEGIN
          REPEAT
            lptr:=lptr+1;
            IF lptr>LENGTH(line) THEN
            BEGIN
              WRITELN(g,line);
              READLN(f,line);
              lptr:=1
            END
          UNTIL line[lptr] = '}';
          lptr:=lptr+1
        END;
        IF line[lptr]='''' THEN
        BEGIN
          REPEAT
            lptr:= lptr + 1
          UNTIL line[lptr]= '''';
          lptr:= lptr+1
        END;
        IF line[lptr] IN ['A'..'Z','a'..'z'] THEN
        BEGIN
          wptr:=1;
          id:='';
          REPEAT
            id := CONCAT(id,line[lptr+wptr-1]);
            wptr:=wptr+1
          UNTIL NOT (line[lptr+wptr-1] IN ['A'..'Z','a'..'z'])
                 OR (lptr+wptr-1 > LENGTH(line));
          UpperCase(id);
          i:=1;
          found:=FALSE;
          WHILE (i<=reserved) AND (NOT found) DO
          BEGIN
            IF id=key[i] THEN
            BEGIN
              found:=TRUE;
              line[lptr]:=UPCASE(line[lptr])
            END;
            i:=i+1
          END;
          lptr:=lptr+wptr
        END
        ELSE lptr:=lptr+1
      END
    END;
    WRITELN(g,line);
    READLN(f,line)
  END;
  CLOSE(f);
  CLOSE(g)
END;                                                     { -- Pr. CaseFix -- }

BEGIN                                                       { Hoofdprogramma }
  LowCase;
  IF Exists('tempfile',r) AND Exists(dest,w) THEN CaseFix;
  ASSIGN(f,'tempfile');
  ERASE(f);
END.
