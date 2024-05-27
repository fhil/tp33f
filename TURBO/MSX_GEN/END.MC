
         INCLUDE STDIO.INC

         INCLUDE LIBDEFS.INC

         PUBLIC TURBOERRORMESSAGES
;         PUBLIC L7BF5

TURBOERRORMESSAGES:
         DB  1 ,' are not allowed',0DH,0AH
	DB  2 ,' can not be',0DH,0AH
	DB  3 ,' constant',0DH,0AH
	DB  4 ,' does not',0DH,0AH
	DB  5 ,' expression',0dh,0ah
         DB  6 ,' identifier',0dh,0ah
         DB  7 ,' file',0dh,0ah
         DB  8 ,' here',0dh,0ah
         DB 0bh,'Integer',0dh,0ah
         DB 0ch,'File',0dh,0ah
         DB 0eh,'Illegal',0dh,0ah
         DB 0fh,' or',0dh,0ah
         DB 10h,'Undefined',0dh,0ah
         DB 11h,' match',0dh,0ah
         DB 12h,' real',0dh,0ah
         DB 13h,'String',0dh,0ah
         DB 14h,'Textfile',0dh,0ah
         DB 15h,' out of range',0dh,0ah
         DB 16h,' variable',0dh,0ah
         DB 17h,' overflow',0dh,0ah
         DB 18h,' expected',0dh,0ah
         DB 19h,' type',0dh,0ah
         DB 1bh,'Invalid',0dh,0ah
         DB 1dh,' pointer',0dh,0ah
         DB 1eh,' longint',0dh,0ah

         DB '01',27h,';',27h,18h,0dh,0ah
         DB '02',27h,':',27h,18h,0dh,0ah
         DB '03',27h,',',27h,18h,0dh,0ah
         DB '04',27h,'(',27h,18h,0dh,0ah
         DB '05',27h,')',27h,18h,0dh,0ah
         DB '06',27h,'=',27h,18h,0dh,0ah
         DB '07',27h,':=',27h,18h,0dh,0ah
         DB '08',27h,'[',27h,18h,0dh,0ah
         DB '09',27h,']',27h,18h,0dh,0ah
         DB '10',27h,'.',27h,18h,0dh,0ah
         DB '11',27h,'..',27h,18h,0dh,0ah
         DB '12BEGIN',18h,0dh,0ah
         DB '13DO',18h,0dh,0ah
         DB '14END',18h,0dh,0ah
         DB '15OF',18h,0dh,0ah
         DB '16PROCEDURE or FUNCTION',18h,0dh,0ah
         DB '17THEN',18h,0dh,0ah
         DB '18TO',0fh,' DOWNTO',18h,0dh,0ah
         DB '19Byte',16h,18h,0dh,0ah
         DB '20Boolean',05h,18h,0dh,0ah
         DB '21',0ch,16h,18h,0dh,0ah
         DB '22',0BH,03H,18h,0dh,0ah
         DB '23',0bh,05h,18h,0dh,0ah
         DB '24',0bh,16h,18h,0dh,0ah
         DB '25',0bh,',',12h,0fh,1eh,03h,18h,0dh,0ah  ; changed 'longint'
         DB '26',0bh,',',12h,0fh,1eh,05h,18h,0dh,0ah  ; changed 'longint'
         DB '27',0bh,',',12h,0fh,1eh,16h,18h,0dh,0ah  ; changed 'longint'
         DB '28Pointer',16h,18h,0dh,0ah
         DB '29Record',16h,18h,0dh,0ah
         DB '30Simple',19h,18h,0dh,0ah
         DB '31Simple',05h,18h,0dh,0ah
         DB '32',13h,03h,18h,0dh,0ah
         DB '33',13h,05h,18h,0dh,0ah
         DB '34',13h,16h,18h,0dh,0ah
         DB '35',14h,18h,0dh,0ah
         DB '36Type',06h,18h,0dh,0ah
         DB '37Untyped',07h,18h,0dh,0ah
         DB '40',10h,' label',0dh,0ah
         DB '41Unknown',06h,0fh,' syntax error',0dh,0ah
         DB '42',10h,1dh,19h,' in preceding',19h,' definitions',0dh,0ah
         DB '43Duplicate',06h,0fh,' label',0dh,0ah
         DB '44Type mismatch',0dh,0ah
         DB '45',03h,15h,0dh,0ah
         DB '46',03h,' and CASE selector',19h,04h,11h,0dh,0ah
         DB '47Operand',19h,'(s)',04h,11h,' operator',0dh,0ah
         DB '48',1bh,' result',19h,0dh,0ah
         DB '49',1bh,' ',13h,' length',0dh,0ah
         DB '50',13h,03h,' length',04h,11h,19h,0dh,0ah
         DB '51',1bh,' subrange base',19h,0dh,0ah
         DB '52Lower bound > upper bound',0dh,0ah
         DB '53Reserved word',0dh,0ah
         DB '54',0eh,' assignment',0dh,0ah
         DB '55',13h,03h,' exceeds line',0dh,0ah
         DB '56Error in integer',03h,0dh,0ah
         DB '57Error in',12h,03h,0dh,0ah

	; 'Illegal character in identifier'
         DB '58',0eh,' character in',06h,0dh,0ah

         DB '60',03h,'s',01h,08h,0dh,0ah

	; Files and pointers are not allowed here
         DB '61',0ch,'s and',1dh,'s',01h,08h,0dh,0ah

         DB '62Structured',16h,'s',01h,08h,0dh,0ah
         DB '63',14h,'s',01h,08h,0dh,0ah
         DB '64',14h,'s and untyped',07h,'s',01h,08h,0dh,0ah
         DB '65Untyped',07h,'s',01h,08h,0dh,0ah
         DB '66I/O',01h,0dh,0ah
         DB '67',0ch,'s must be',16h,' parameters',0dh,0ah
         DB '68',0ch,' components',02h,07h,'s',0dh,0ah
         DB '69',1bh,0fh,'dering of fields',0dh,0ah
         DB '70Set base',19h,15h,0dh,0ah
         DB '71',1bh,' GOTO',0dh,0ah
         DB '72Label not within current block',0dh,0ah
         DB '73',10h,' FORWARD procedure(s)',0dh,0ah
         DB '74INLINE error',0dh,0ah
         DB '75',0eh,' use of ABSOLUTE',0dh,0ah
         DB '76Overlay cannot be forwarded',0dh,0ah
         DB '90',0ch,' not found',0dh,0ah
         DB '91Unexpected end of source',0dh,0ah
         DB '96No nesting of include files',0dh,0ah
         DB '97Too many nested WITH''s',0dh,0ah
         DB '98Memory',17h,0dh,0ah
         DB '99Compiler',17h,0dh,0ah

         DB 1ah                     ; ctrl-z as end of file marker

L7BF5:
         END

