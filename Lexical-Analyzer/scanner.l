%{
	#include <stdio.h>
	#include <string.h>
	

	struct symbols
	{
		char name[100];
		char type[100];
		int length;
	}STable[1001];

	struct constants
	{
		char name[100];
		char type[100];
		int length;
	}CTable[1001];

	int hash(char *str)
	{
		int value = 0;
		for(int i = 0 ; i < strlen(str) ; i++)
		{
			value = 10*value + (str[i] - 'A');
			value = value % 1001;
			while(value < 0)
				value = value + 1001;
		}
		return value;
	}

	int lookupSTable(char *str)
	{
		int value = hash(str);
		if(STable[value].length == 0)
		{
			return 0;
		}
		else if(strcmp(STable[value].name,str)==0)
		{
			return 1;
		}
		else
		{
			for(int i = value + 1 ; i!=value ; i = (i+1)%1001)
	    	{
	    		if(strcmp(STable[i].name,str)==0)
	    		{
	    			return 1;
	    		}
	    	}
	    	return 0;
	    }
	}

	int lookupCTable(char *str)
	{
		int value = hash(str);
		if(CTable[value].length == 0)
			return 0;
		else if(strcmp(CTable[value].name,str)==0)
			return 1;
		else
		{
			for(int i = value + 1 ; i!=value ; i = (i+1)%1001)
			{
				if(strcmp(CTable[i].name,str)==0)
				{
					return 1;
				}
			}
			return 0;
		}
	}

	void insertSTable(char *str1, char *str2)
	{
		if(lookupSTable(str1))
		{
		    return;
	    }
		else
		{
			int value = hash(str1);
			if(STable[value].length == 0)
			{
				strcpy(STable[value].name,str1);
				strcpy(STable[value].type,str2);
				STable[value].length = strlen(str1);
				return;
			}

			int pos = 0;

			for (int i = value + 1 ; i!=value ; i = (i+1)%1001)
			{
				if(STable[i].length == 0)
				{
					pos = i;
					break;
				}
			}

			strcpy(STable[pos].name,str1);
			strcpy(STable[pos].type,str2);
			STable[pos].length = strlen(str1);
		}
	}

	void insertCTable(char *str1, char *str2)
	{
		if(lookupCTable(str1))
			return;
		else
		{
			int value = hash(str1);
			if(CTable[value].length == 0)
			{
				strcpy(CTable[value].name,str1);
				strcpy(CTable[value].type,str2);
				CTable[value].length = strlen(str1);
				return;
			}

			int pos = 0;

			for (int i = value + 1 ; i!=value ; i = (i+1)%1001)
			{
				if(CTable[i].length == 0)
				{
					pos = i;
					break;
				}
			}

			strcpy(CTable[pos].name,str1);
			strcpy(CTable[pos].type,str2);
			CTable[pos].length = strlen(str1);
		}
	}

	void printSTable()
	{
		for(int i = 0 ; i < 1001 ; i++)
		{
			if(STable[i].length == 0)
			{
				continue;
			}

			printf("%s\t%s\n",STable[i].name, STable[i].type);
		}
	}

	void printCTable()
	{
		for(int i = 0 ; i < 1001 ; i++)
		{
			if(CTable[i].length == 0)
				continue;

			printf("%s\t%s\n",CTable[i].name, CTable[i].type);
		}
	}

%}


%%
\n   {yylineno++;}
([#][" "]*("include")[ ]*([<]?)([A-Za-z]+)[.]?([A-Za-z]*)([>]?))/["\n"|\/|" "|"\t"] {printf("%s \t-Pre Processor directive\n",yytext);}	//Matches #include<stdio.h>
([#][" "]*("define")[" "]*([A-Za-z]+)(" ")*[0-9]+)/["\n"|\/|" "|"\t"] {printf("%s \t-Macro\n",yytext);} //Matches macro
\/\/(.*) {printf("%s \t- single line comment\n", yytext);}				
\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/  {printf("%s \t- multi line comment\n", yytext);}
[ \n\t] ;
; {printf("%s \t- semicolon delimiter\n", yytext);}
, {printf("%s \t- comma delimiter\n", yytext);}
\{ {printf("%s \t- opening braces\n", yytext);}
\} {printf("%s \t- closing braces\n", yytext);}
\( {printf("%s \t- opening brackets\n", yytext);}
\) {printf("%s \t- closing brackets\n", yytext);}
\[ {printf("%s \t- square opening brackets\n", yytext);}
\] {printf("%s \t- square closing brackets\n", yytext);}
\: {printf("%s \t- colon delimiter\n", yytext);}
\\ {printf("%s \t- fslash\n", yytext);}
\. {printf("%s \t- dot delimiter\n", yytext);}
auto|break|case|char|const|continue|default|do|double|else|enum|extern|float|for|goto|if|int|long|register|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|void|volatile|while|main/[\(|" "|\{|;|:|"\n"|"\t"] {printf("%s \t- keyword\n", yytext); insertSTable(yytext, "keyword");}
\"[^\n]*\"/[;|,|\)] {printf("%s \t- string constant\n", yytext); insertCTable(yytext,"string constant");}
\'[A-Z|a-z]\'/[;|,|\)|:] {printf("%s \t- character constant\n", yytext); insertCTable(yytext,"character constant");}
[a-z|A-Z]([a-z|A-Z]|[0-9])*/\[ {printf("%s \t- array identifier\n", yytext); insertSTable(yytext, "identifier");}

[[<][=]|[>][=]|[=][=]|[!][=]|[>]|[<]|[\|][\|]|[&][&]|[\!]|[=]|[\^]|[\+][=]|[\-][=]|[\*][=]|[\/][=]|[\%][=]|[\+][\+]|[\-][\-]|[\+]|[\-]|[\*]|[\/]|[\%]|[&]|[\|]|[~]|[<][<]|[>][>]]/[a-z]|[0-9]|;|" "|[A-Z]|\(|\"|\'|\)|\n|\t {printf("%s \t- operator\n", yytext);} 

[1-9][0-9]*|0/[;|,|" "|\)|<|>|=|\!|\||&|\+|\-|\*|\/|\%|~|\]|\}|:|\n|\t|\^] {printf("%s \t- number constant\n", yytext); insertCTable(yytext, "number constant");}
([0-9]*)\.([0-9]+)/[;|,|" "|\)|<|>|=|\!|\||&|\+|\-|\*|\/|\%|~|\n|\t|\^] {printf("%s \t- floating constant\n", yytext); insertCTable(yytext, "floating constant");}
[A-Za-z_][A-Za-z_0-9]*/[" "|;|,|\(|\)|<|>|=|\!|\||&|\+|\-|\*|\/|\%|~|\n|\.|\{|\^|\t] {printf("%s \t- identifier\n", yytext); insertSTable(yytext, "identifier");}


(.?) {
		if(yytext[0]=='#')
		{
       		printf("Error in Pre-Processor directive at line no. %d\n",yylineno);
       	}
		else if(yytext[0]=='"')
       	{
       		printf("ERR_INCOMPLETE_STRING at line no. %d\n",yylineno);
       	}
	    else if(yytext[0]=='/')
	    {
       		printf("ERR_UNMATCHED_COMMENT at line no. %d\n",yylineno);
       	}
       	else
       	{
       		printf("ERROR at line no. %d\n",yylineno);
       	}
       	printf("%s\n", yytext);
       	return 0;
}

%%

int main(int argc , char **argv){

    printf("====================================================================\n");

	int i;
	for (i=0;i<1001;i++){
		STable[i].length=0;
		CTable[i].length=0;
	}

	yyin = fopen(argv[1],"r");
	yylex();
	
	printf("\n\nSYMBOL TABLE\n\n");
	printSTable();
	printf("\n\nCONSTANT TABLE\n\n");
	printCTable();
}

int yywrap(){
    return 1;
}