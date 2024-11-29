%{
    #include <stdio.h>
    #include <string> 
    #include "parser.hpp"

    extern int yylex();
    void token(const char* s, const char* type);

    extern FILE* token_file; // Declare the file pointer from main.cpp
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
BACKSLASH           "\\"

NEWLINE             "\n"
TAB                 "\t"

%%

^{HASH}{SPACE}                                      { token("HASH", "#"); return H1; }
^{HASH}{HASH}{SPACE}                                { token("HASH", "##"); return H2; }
^{HASH}{HASH}{HASH}{SPACE}                          { token("HASH", "###"); return H3; }
^{HASH}{HASH}{HASH}{HASH}{SPACE}                    { token("HASH", "####"); return H4; }
^{HASH}{HASH}{HASH}{HASH}{HASH}{SPACE}              { token("HASH", "#####"); return H5; }
^{HASH}{HASH}{HASH}{HASH}{HASH}{HASH}{SPACE}        { token("HASH", "######"); return H6; }

{SPACE}{2,}{NEWLINE}                                { token("LINEBREAK", "  "); return LINEBREAK; }
{NEWLINE}{3,}                                       { token("PARA", "\\n\\n\\n"); return ENDLIST; }
{NEWLINE}{NEWLINE}                                  { token("PARA", "\\n\\n"); return PARA; }                                          

{NEWLINE}{LETTER}                                   {   token("SBREAK", "NEWLINE+TEXT");
                                                        yylval.strval = new std::string(yytext); 
                                                        yylval.strval->at(0) = ' ';
                                                        return TEXT;
                                                    }
{NEWLINE}                                           { token("NEWLINE", "\\n"); return NEWLINE; }

{SPACE}{1,}                                         {   token("SPACE", " "); 
                                                        yytext[1] = '\0';
                                                        yylval.strval = new std::string(yytext);
                                                        return TEXT;
                                                    }
^{NUM}{DOT}{SPACE}                                  { token("ORDERED", "1."); return ORDERED; }
^{MINUS}{SPACE}                                     { token("UNORDERED", "-"); return UNORDERED; }

{ASTRX}                                             { token("AITALIC", "*"); return AITALIC; }
{USCORE}                                            { token("UITALIC", "_"); return UITALIC; }
{ASTRX}{ASTRX}                                      { token("ABOLD", "**"); return ABOLD; }
{USCORE}{USCORE}                                    { token("UBOLD", "__"); return UBOLD; }

{LSQRB}                                             { token("LSQRB", "["); return LSQRB; }
{RSQRB}                                             { token("RSQRB", "]"); return RSQRB; }
{LPAR}                                              { token("LPAR", "("); return LPAR; }
{RPAR}                                              { token("RPAR", ")"); return RPAR; }
{EXCLA}{LSQRB}                                      { token("IMGOPEN", "!["); return IMGOPEN; }
{TEXT}                                              {   token("TEXT", yytext); 
                                                        yylval.strval = new std::string(yytext); 
                                                        return TEXT;
                                                    }

.                                                   { token("OTHER", yytext); }

%%

//multiple input files karta yywrap function
 
int yywrap(){
    return 1;
}

/*
Function to print const char* to the token file
*/
void token(const char* s, const char* type){
    if (token_file == NULL) {
        fprintf(stderr, "Token file not initialized.\n");
        return;
    }
    fprintf(token_file, "%s \t\t %s\n", type, s);
}
