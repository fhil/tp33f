#include <stdio.h>

int readline(FILE *in, char *text)
{
	int c;

	while ( ((c=getc(in)) != -1) && (c != 0x0a) ) {
		*text++ = c;
	}

	*text = '\0';

	return c;
}

int main(int argc, char *argv[])
{
	char value[100];
	char label[100];
	char text[10000];
	FILE *in, *out;
	int i;

	if (argc < 2)
	{
		fprintf(stderr,"SYNTAX: <symbol file> <include file>\n");
		return 1;
	}

	if ((in = fopen(argv[1],"rt")) == NULL)
	{
		fprintf(stderr,"Cannot open input file '%s'.\n",argv[1]);
		return 1;
	}
	if ((out = fopen(argv[2],"wt")) == NULL)
	{
		fprintf(stderr,"Cannot open output file '%s'.\n",argv[2]);
		return 1;
	}

	while (readline(in,(char *)&text) != -1) {


		if ( (text[1]=='0') && (text[2]=='0') &&
		     (text[3]=='0') && (text[4]=='0') &&
		     (text[5]==':') && (text[10]==' ') &&
		     (text[15]==' ') && (text[16] == ' ') &&
                     (text[17]=='_') &&
		     (strlen(text) > 17) ) {
			text[10] = '\0';

			i = 17;
			while ((text[i]!=' ') && (text[i]!='\0')) {
				i++;
			}
			text[i] = '\0';

                        fprintf(out,"_%s EQU offset 0%sh\n",&text[18],&text[6]);
		}
	}

	/*
	while (fscanf(in,"%s",value)==1) {
		fscanf(in,"%s",label);

		if (label[0] == '_') {
			fprintf(out,"%s EQU %sh\n",label,value);
		}
	}
	*/
	fclose(in);
	fclose(out);
	return 0;
}
