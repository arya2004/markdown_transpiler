%{
    #include <string>
    #include <map>
    #include <fstream>

    extern char* yytext;
    std::string* outStr;

    // Declare the symbol table as a map
    std::map<std::string, int> symbolTable;
%}

%code requires {
    #include <cstdio>
    #include <string>
    extern int yylex(void);
    static void yyerror(const char* s); 
    std::string* getHtmlOut(void);
}

%union {
    std::string* strval; 
}

%token H1 H2 H3 H4 H5 H6 
%token ABOLD UBOLD 
%token AITALIC UITALIC 
%token ORDERED UNORDERED
%token PARA LINEBREAK NEWLINE ENDLIST
%token LSQRB RSQRB LPAR RPAR IMGOPEN
%token <strval> TEXT

%left H1 H2 H3 H4 H5 H6 PARA LINEBREAK

%start convertList

%type <strval> convertList
%type <strval> blocks
%type <strval> block
%type <strval> paragraph
%type <strval> contents
%type <strval> content
%type <strval> lines
%type <strval> line

%type <strval> paragraphs
%type <strval> headings

%type <strval> orderedLists
%type <strval> orderedList

%type <strval> unorderedLists
%type <strval> unorderedList

%%

convertList: NEWLINE convertList    {$$ = $2;}
        | PARA convertList          {$$ = $2;}
        | ENDLIST convertList       {$$ = $2;}
        | blocks                    {
                                        outStr = $1;
                                        // Output the symbol table to a file
                                        std::ofstream symFile("symbol_table.txt");
                                        for(auto it = symbolTable.begin(); it != symbolTable.end(); ++it) {
                                            symFile << it->first << ": " << it->second << "\n";
                                        }
                                        symFile.close();
                                    }
   
blocks : block
       | blocks block {
		                $$ = new std::string(*$1 + *$2);
		                delete $1;
		                delete $2;
	                }

block : paragraphs
      | headings
      | orderedLists                    { $$ = new std::string("<ol>" + *$1 + "</ol>"); delete $1; }
      | unorderedLists                  { $$ = new std::string("<ul>" + *$1 + "</ul>"); delete $1; } 

orderedLists : orderedList
            | orderedLists orderedList  { $$ = new std::string(*$1 + *$2); delete $1; delete $2; }


orderedList: ORDERED content NEWLINE    { $$ = new std::string("<li>" + *$2 + "</li>");
                                          delete $2; }
            | ORDERED content PARA      { $$ = new std::string("<li>" + *$2 + "</li>");
                                          delete $2; }


unorderedLists: unorderedList
            | unorderedLists unorderedList { $$ = new std::string(*$1 + *$2); delete $1; delete $2; }


unorderedList: UNORDERED content NEWLINE    { $$ = new std::string("<li>" + *$2 + "</li>");
                                              delete $2; }
            | UNORDERED content PARA        { $$ = new std::string("<li>" + *$2 + "</li>");
                                              delete $2; }

paragraphs: paragraph { 
                        if( $1->length() > 6){
                            if( $1->substr(0,3) == "<p>" && $1->substr($1->length()-4,4) == "</p>"){
                                        $$ = $1;
                            }
                            else{
                                $$ = new std::string("<p>" + *$1 + "</p>");
                                delete $1;
                            }
                        }    
                        else{ 
                            $$ = new std::string("<p>" + *$1 + "</p>");
                            delete $1;
                        }
		            }

    | paragraphs paragraph { 
	                        std::string* temp;

                            if( $2->length() > 6){
                                if( $2->substr(0,3) == "<p>" && 
                                    $2->substr($2->length()-4,4) == "</p>"){
                                    temp = $2;
                                }
                                
                                else{
                                    temp = new std::string("<p>" + *$2 + "</p>");
                                    delete $2;
                                }
                            }    
                            else{ 
                                temp = new std::string("<p>" + *$2 + "</p>");
                                delete $2;
                            }
                            $$ = new std::string(*$1 + *temp);
                            delete $1;
                            delete temp;
                        }


paragraph: contents
    | paragraph PARA                { $$ = new std::string("<p>" + *$1 + "</p>"); 
                                      delete $1;}

    | paragraph LINEBREAK paragraph { $$ = new std::string(*$1 + "<br>" + *$3); 
                                      delete $1; }
    | paragraph NEWLINE
;

headings: 
        H1 contents PARA { 
                    $$ = new std::string("<h1>" + *$2 + "</h1>");
                    delete $2;
                }

        | H2 contents PARA {
                    $$ = new std::string("<h2>" + *$2 + "</h2>");
                    delete $2;
                }
        | H3 contents PARA {
                    $$ = new std::string("<h3>" + *$2 + "</h3>");
                    delete $2;
                } 
        | H4 contents PARA{
                    $$ = new std::string("<h4>" + *$2 + "</h4>");
                    delete $2;
                } 
        | H5 contents PARA{
                    $$ = new std::string("<h5>" + *$2 + "</h5>");
                    delete $2;
                }
        | H6 contents PARA{
                    $$ = new std::string("<h6>" + *$2 + "</h6>");
                    delete $2;
                }
        | H1 contents NEWLINE { 
                    $$ = new std::string("<h1>" + *$2 + "</h1>");
                    delete $2;
                }

        | H2 contents NEWLINE {
                    $$ = new std::string("<h2>" + *$2 + "</h2>");
                    delete $2;
                }
        | H3 contents NEWLINE {
                    $$ = new std::string("<h3>" + *$2 + "</h3>");
                    delete $2;
                } 
        | H4 contents NEWLINE {
                    $$ = new std::string("<h4>" + *$2 + "</h4>");
                    delete $2;
                } 
        | H5 contents NEWLINE {
                    $$ = new std::string("<h5>" + *$2 + "</h5>");
                    delete $2;
                }
        | H6 contents NEWLINE {
                    $$ = new std::string("<h6>" + *$2 + "</h6>");
                    delete $2;
                }
         
;


contents : content
        | contents content {
                    $$ = new std::string(*$1 + *$2);
                    delete $1;
                    delete $2;
                }
;

content: lines
    | AITALIC content AITALIC   { $$ = new std::string("<em>" + *$2 + "</em>");
                                  delete $2; }

    | UITALIC content UITALIC   { $$ = new std::string("<em>" + *$2 + "</em>");
                                  delete $2; }

    | ABOLD   content  ABOLD    { $$ = new std::string("<strong>" + *$2 + "</strong>");
                                  delete $2; }

    | UBOLD   content  UBOLD    { $$ = new std::string("<strong>" + *$2 + "</strong>");
                                  delete $2; }

    | ABOLD AITALIC content ABOLD AITALIC   { $$ = new std::string("<strong><em>" + *$3 + "</em></strong>");
                                              delete $3; }

    | UBOLD UITALIC content UBOLD UITALIC   { $$ = new std::string("<strong><em>" + *$3 + "</em></strong>");
                                              delete $3; }

    | LSQRB lines RSQRB LPAR lines RPAR     { $$ = new std::string("<a href=\"" + *$5 +"\">" + *$2 + "</a>");
                                              delete $2;
                                              delete $5; }
    | IMGOPEN lines RSQRB LPAR lines RPAR   { $$ = new std::string("<img src=\"" + *$5 +"\" alt=\"" + *$2 + "\">");
                                              delete $2;
                                              delete $5; } 

lines: line
    | lines line            {$$ = new std::string(*$1 + *$2); delete $1; delete $2;}


line: TEXT { 
            $$ = $1; 
            // Insert TEXT into the symbol table
            symbolTable[*$1]++; 
          }
    | line TEXT { 
                  $$ = new std::string(*$1 + *$2); 
                  // Insert TEXT into the symbol table
                  symbolTable[*$2]++; 
                  delete $1; delete $2; 
                }

%%

/*
Function prints error code to stderr
*/
void yyerror(const char *s){
    fprintf(stderr, "error: %s\n", s);
}

/*
Interface function to return outStr
*/
std::string* getHtmlOut(){
    return outStr; 
}
