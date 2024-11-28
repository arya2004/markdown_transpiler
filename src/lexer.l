%{
    #include <stdio.h>
    #include <string> 
    #include "parser.hpp"

    extern int yylex();
    void token(const char* s);

    FILE *ftokens; // Add file pointer for tokens output

    void init_lexer(){
        ftokens = fopen("tokens.txt", "w");
        if(ftokens == NULL){
            fprintf(stderr, "Error: Unable to open tokens.txt for writing.\n");
            exit(1);
        }
    }

    void close_lexer(){
        fclose(ftokens);
    }
%}


ALPA                [a-zA-Z]
NUM                 [0-9]
PUNC                [@$%^&\{\};"'<>,?/~`=\\]
SPECIAL             [\#\!\|\:\+\-\.]
SPACE               " "
LETTER              (({ALPA})+({ALPA}|{NUM}|{PUNC}|{SPECIAL})*)|(({NUM})({ALPA})+)
TEXT                ({LETTER})+

HASH                "#"
ASTRX               "*"
USCORE              "_"
EXCLA               \!
LSQRB               \[
RSQRB               \]
LPAR                \(
RPAR                \)
PIPE                "|"
COLON               ":"
PLUS                "+"
MINUS               "-"
DOT                 "."
BACKSLASH           "\"

NEWLINE             "\n"
TAB                 "\t"

%%
^{HASH}{SPACE}                                      { token("H1"); return H1; }
^{HASH}{HASH}{SPACE}                                { token("H2"); return H2; }
^{HASH}{HASH}{HASH}{SPACE}                          { token("H3"); return H3; }
^{HASH}{HASH}{HASH}{HASH}{SPACE}                    { token("H4"); return H4; }
^{HASH}{HASH}{HASH}{HASH}{HASH}{SPACE}              { token("H5"); return H5; }
^{HASH}{HASH}{HASH}{HASH}{HASH}{HASH}{SPACE}        { token("H6"); return H6; }

{SPACE}{2,}{NEWLINE}                                { token("LINEBREAK"); return LINEBREAK; }
{NEWLINE}{3,}                                       { token("PARA"); return ENDLIST; }
{NEWLINE}{NEWLINE}                                  { token("PARA"); return PARA; }                                          

{NEWLINE}{LETTER}                                   {   token("SBREAK");
                                                        yylval.strval = new std::string(yytext); 
                                                        yylval.strval->at(0) = ' ';
                                                        return TEXT;
                                                    }
{NEWLINE}                                           { token("NEWLINE"); return NEWLINE; }

{SPACE}{1,}                                         {   token("SPACE");
                                                        yytext[1] = '\0';
                                                        yylval.strval = new std::string(yytext);
                                                        return TEXT;
                                                    }
^{NUM}{DOT}{SPACE}                                  { token("ORDERED"); return ORDERED; }
^{MINUS}{SPACE}                                     { token("UNORDERED"); return UNORDERED; }

{ASTRX}                                             { token("AITALIC"); return AITALIC; }
{USCORE}                                            { token("UITALIC"); return UITALIC; }
{ASTRX}{ASTRX}                                      { token("ABOLD"); return ABOLD; }
{USCORE}{USCORE}                                    { token("UBOLD"); return UBOLD; }

{LSQRB}                                             { token("LSQRB"); return LSQRB; }
{RSQRB}                                             { token("RSQRB"); return RSQRB; }
{LPAR}                                              { token("LPAR"); return LPAR; }
{RPAR}                                              { token("RPAR"); return RPAR; }
{EXCLA}{LSQRB}                                      { token("IMGOPEN"); return IMGOPEN; }
{TEXT}                                              {   token("TEXT"); 
                                                        yylval.strval = new std::string(yytext); 
                                                        return TEXT;
                                                    }

.                                                   { token("OTHER"); }

%%

//multiple input files karta yywrap function
 
int yywrap(){
    return 1;
}

/*
Fuction to print const char* to stdout
*/
void token(const char* s){
    fprintf(ftokens, "%s\n", s);
    return;
}