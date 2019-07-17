/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;
/*
 *  Add Your own definitions here
 */
#include <bits/stdc++.h>

%}
UNDERSCORE     \_
DIGIT     [0-9]
CHAR      [a-zA-Z]
space         [ \t\n\f\r\v]+

/*
 * Define names for regular expressions here.
 */

DARROW          =>

%%
{space}       {}
 /*
  *	one line comments
  */

\-\-[^.]* {}
 /*
  *  Nested comments
  */
\(\*[^(\*\))]*\*\)    {}

 /*
  *  operators
  */
[\:\)\(\{\}\;\.\+\-\~\>\<\*\,\[\]]        {}

=                     {return(ASSIGN);}
 /*
  *  The multiple-character operators.
  */
{DARROW}		{ return (DARROW); }
->|=>|=<			{ return (DARROW); }
 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */
(?:class)   {return (CLASS);}
(?:else)      {return (ELSE);}
(?:fi)        {return (FI);}
(?:if)        {return (IF);}
(?:in)        {return (IN);}
(?:inherits)  {return (INHERITS);}
(?:isvoid)    {return (ISVOID);}
(?:let)       {return (LET);}
(?:loop)      {return (LOOP);}
(?:pool)      {return (POOL);}
(?:then)      {return (THEN);}
(?:while)     {return (WHILE);}
(?:case)      {return (CASE);}
(?:esac)      {return (ESAC);}
(?:new)       {return (NEW);}
(?:of)        {return (OF);}
(?:not)       {return (NOT);}
f(?:alse)     {
	cool_yylval.boolean = 0;
	return (BOOL_CONST);
}
t(?:rue)      {
	cool_yylval.boolean = 1;
	return (BOOL_CONST);
}

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */
\"[^\"]*\"   {
	
	if(yyleng>509){
		cool_yylval.error_msg = "String constant too long";
		return (ERROR);
	}
	cool_yylval.symbol = stringtable.add_string(yytext);
	return(STR_CONST);        	  
}
\'[^\']\'     {
	
	cool_yylval.symbol = stringtable.add_string(yytext);
	return(STR_CONST);  

}
{DIGIT}*     {
	cool_yylval.symbol = inttable.add_string(yytext);
	return (INT_CONST);
}
self|SELF_TYPE    {	
	cool_yylval.symbol = idtable.add_string(yytext);
	return (OBJECTID);
}
{CHAR}[\_a-zA-Z0-9]*   {
	if(isupper(yytext[0])){
		cool_yylval.symbol = idtable.add_string(yytext);
		return (TYPEID);
	}
	else{
		cool_yylval.symbol = idtable.add_string(yytext);
		return (OBJECTID);
	}

}
\"[^\"]*   {
	cool_yylval.error_msg = "EOF in string constant";
	return (ERROR);
}
\"[^\\n]*\\n   {
	cool_yylval.error_msg = "Unterminated string constant";
	return (ERROR);

}
\"[^\\0]*\\0   {
	cool_yylval.error_msg = "String contains null character";
	return (ERROR);

}
\*\)    {
	cool_yylval.error_msg = "Unmatched *)";
	return (ERROR);
}
\(\*[^(\*\))]*    {
	cool_yylval.error_msg = "EOF in comment";
	return (ERROR);

}

[\32-\127]   {
	cool_yylval.error_msg = yytext;
	return (ERROR);
}


%%
