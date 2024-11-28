%{
    #include <string>

    extern char* yytext;
    std::string* outStr;

    FILE *fsyntax;
    FILE *fsemantic;
    FILE *fast;

    void init_parser(){
        fsyntax = fopen("syntax.txt", "w");
        if(fsyntax == NULL){
            fprintf(stderr, "Error: Unable to open syntax.txt for writing.\n");
            exit(1);
        }
        fsemantic = fopen("semantic.txt", "w");
        if(fsemantic == NULL){
            fprintf(stderr, "Error: Unable to open semantic.txt for writing.\n");
            exit(1);
        }
        fast = fopen("ast.txt", "w");
        if(fast == NULL){
            fprintf(stderr, "Error: Unable to open ast.txt for writing.\n");
            exit(1);
        }
    }

    void close_parser(){
        fclose(fsyntax);
        fclose(fsemantic);
        fclose(fast);
    }

    void write_semantic_output(){
        fprintf(fsemantic, "%s\n", outStr->c_str());
    }
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

convertList:
      NEWLINE convertList  { $$ = $2; fprintf(fsyntax, "convertList -> NEWLINE convertList\n"); }
    | PARA convertList     { $$ = $2; fprintf(fsyntax, "convertList -> PARA convertList\n"); }
    | ENDLIST convertList  { $$ = $2; fprintf(fsyntax, "convertList -> ENDLIST convertList\n"); }
    | blocks               { outStr = $1; fprintf(fsyntax, "convertList -> blocks\n"); }
    ;

blocks:
      block                { $$ = $1; fprintf(fsyntax, "blocks -> block\n"); }
    | blocks block         {
                              $$ = new std::string(*$1 + *$2);
                              delete $1;
                              delete $2;
                              fprintf(fsyntax, "blocks -> blocks block\n");
                            }
    ;

block:
      paragraphs           { $$ = $1; fprintf(fsyntax, "block -> paragraphs\n"); }
    | headings             { $$ = $1; fprintf(fsyntax, "block -> headings\n"); }
    | orderedLists         {
                              $$ = new std::string("<ol>" + *$1 + "</ol>");
                              delete $1;
                              fprintf(fsyntax, "block -> orderedLists\n");
                           }
    | unorderedLists       {
                              $$ = new std::string("<ul>" + *$1 + "</ul>");
                              delete $1;
                              fprintf(fsyntax, "block -> unorderedLists\n");
                           }
    ;

orderedLists:
      orderedList          { $$ = $1; fprintf(fsyntax, "orderedLists -> orderedList\n"); }
    | orderedLists orderedList {
                                  $$ = new std::string(*$1 + *$2);
                                  delete $1;
                                  delete $2;
                                  fprintf(fsyntax, "orderedLists -> orderedLists orderedList\n");
                               }
    ;

orderedList:
      ORDERED content NEWLINE {
                                  $$ = new std::string("<li>" + *$2 + "</li>");
                                  delete $2;
                                  fprintf(fsyntax, "orderedList -> ORDERED content NEWLINE\n");
                              }
    | ORDERED content PARA    {
                                  $$ = new std::string("<li>" + *$2 + "</li>");
                                  delete $2;
                                  fprintf(fsyntax, "orderedList -> ORDERED content PARA\n");
                              }
    ;

unorderedLists:
      unorderedList            { $$ = $1; fprintf(fsyntax, "unorderedLists -> unorderedList\n"); }
    | unorderedLists unorderedList {
                                      $$ = new std::string(*$1 + *$2);
                                      delete $1;
                                      delete $2;
                                      fprintf(fsyntax, "unorderedLists -> unorderedLists unorderedList\n");
                                   }
    ;

unorderedList:
      UNORDERED content NEWLINE {
                                    $$ = new std::string("<li>" + *$2 + "</li>");
                                    delete $2;
                                    fprintf(fsyntax, "unorderedList -> UNORDERED content NEWLINE\n");
                                }
    | UNORDERED content PARA    {
                                    $$ = new std::string("<li>" + *$2 + "</li>");
                                    delete $2;
                                    fprintf(fsyntax, "unorderedList -> UNORDERED content PARA\n");
                                }
    ;

paragraphs:
      paragraph                  {
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
                                    fprintf(fsyntax, "paragraphs -> paragraph\n");
                                }
    | paragraphs paragraph       {
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
                                    fprintf(fsyntax, "paragraphs -> paragraphs paragraph\n");
                                }
    ;

paragraph:
      contents                   { $$ = $1; fprintf(fsyntax, "paragraph -> contents\n"); }
    | paragraph PARA             {
                                    $$ = new std::string("<p>" + *$1 + "</p>");
                                    delete $1;
                                    fprintf(fsyntax, "paragraph -> paragraph PARA\n");
                                 }
    | paragraph LINEBREAK paragraph {
                                        $$ = new std::string(*$1 + "<br>" + *$3);
                                        delete $1;
                                        delete $3;
                                        fprintf(fsyntax, "paragraph -> paragraph LINEBREAK paragraph\n");
                                    }
    | paragraph NEWLINE          { $$ = $1; fprintf(fsyntax, "paragraph -> paragraph NEWLINE\n"); }
    ;

headings:
      H1 contents PARA           {
                                    $$ = new std::string("<h1>" + *$2 + "</h1>");
                                    delete $2;
                                    fprintf(fsyntax, "headings -> H1 contents PARA\n");
                                 }
    | H2 contents PARA           {
                                    $$ = new std::string("<h2>" + *$2 + "</h2>");
                                    delete $2;
                                    fprintf(fsyntax, "headings -> H2 contents PARA\n");
                                 }
    | H3 contents PARA           {
                                    $$ = new std::string("<h3>" + *$2 + "</h3>");
                                    delete $2;
                                    fprintf(fsyntax, "headings -> H3 contents PARA\n");
                                 }
    | H4 contents PARA           {
                                    $$ = new std::string("<h4>" + *$2 + "</h4>");
                                    delete $2;
                                    fprintf(fsyntax, "headings -> H4 contents PARA\n");
                                 }
    | H5 contents PARA           {
                                    $$ = new std::string("<h5>" + *$2 + "</h5>");
                                    delete $2;
                                    fprintf(fsyntax, "headings -> H5 contents PARA\n");
                                 }
    | H6 contents PARA           {
                                    $$ = new std::string("<h6>" + *$2 + "</h6>");
                                    delete $2;
                                    fprintf(fsyntax, "headings -> H6 contents PARA\n");
                                 }
    | H1 contents NEWLINE        {
                                    $$ = new std::string("<h1>" + *$2 + "</h1>");
                                    delete $2;
                                    fprintf(fsyntax, "headings -> H1 contents NEWLINE\n");
                                 }
    | H2 contents NEWLINE        {
                                    $$ = new std::string("<h2>" + *$2 + "</h2>");
                                    delete $2;
                                    fprintf(fsyntax, "headings -> H2 contents NEWLINE\n");
                                 }
    | H3 contents NEWLINE        {
                                    $$ = new std::string("<h3>" + *$2 + "</h3>");
                                    delete $2;
                                    fprintf(fsyntax, "headings -> H3 contents NEWLINE\n");
                                 }
    | H4 contents NEWLINE        {
                                    $$ = new std::string("<h4>" + *$2 + "</h4>");
                                    delete $2;
                                    fprintf(fsyntax, "headings -> H4 contents NEWLINE\n");
                                 }
    | H5 contents NEWLINE        {
                                    $$ = new std::string("<h5>" + *$2 + "</h5>");
                                    delete $2;
                                    fprintf(fsyntax, "headings -> H5 contents NEWLINE\n");
                                 }
    | H6 contents NEWLINE        {
                                    $$ = new std::string("<h6>" + *$2 + "</h6>");
                                    delete $2;
                                    fprintf(fsyntax, "headings -> H6 contents NEWLINE\n");
                                 }
    ;

contents:
      content                    { $$ = $1; fprintf(fsyntax, "contents -> content\n"); }
    | contents content           {
                                    $$ = new std::string(*$1 + *$2);
                                    delete $1;
                                    delete $2;
                                    fprintf(fsyntax, "contents -> contents content\n");
                                 }
    ;

content:
      lines                      { $$ = $1; fprintf(fsyntax, "content -> lines\n"); }
    | AITALIC content AITALIC    {
                                    $$ = new std::string("<em>" + *$2 + "</em>");
                                    delete $2;
                                    fprintf(fsyntax, "content -> AITALIC content AITALIC\n");
                                 }
    | UITALIC content UITALIC    {
                                    $$ = new std::string("<em>" + *$2 + "</em>");
                                    delete $2;
                                    fprintf(fsyntax, "content -> UITALIC content UITALIC\n");
                                 }
    | ABOLD content ABOLD        {
                                    $$ = new std::string("<strong>" + *$2 + "</strong>");
                                    delete $2;
                                    fprintf(fsyntax, "content -> ABOLD content ABOLD\n");
                                 }
    | UBOLD content UBOLD        {
                                    $$ = new std::string("<strong>" + *$2 + "</strong>");
                                    delete $2;
                                    fprintf(fsyntax, "content -> UBOLD content UBOLD\n");
                                 }
    | ABOLD AITALIC content ABOLD AITALIC {
                                            $$ = new std::string("<strong><em>" + *$3 + "</em></strong>");
                                            delete $3;
                                            fprintf(fsyntax, "content -> ABOLD AITALIC content ABOLD AITALIC\n");
                                         }
    | UBOLD UITALIC content UBOLD UITALIC {
                                            $$ = new std::string("<strong><em>" + *$3 + "</em></strong>");
                                            delete $3;
                                            fprintf(fsyntax, "content -> UBOLD UITALIC content UBOLD UITALIC\n");
                                         }
    | LSQRB lines RSQRB LPAR lines RPAR {
                                            $$ = new std::string("<a href=\"" + *$5 +"\">" + *$2 + "</a>");
                                            delete $2;
                                            delete $5;
                                            fprintf(fsyntax, "content -> LSQRB lines RSQRB LPAR lines RPAR\n");
                                         }
    | IMGOPEN lines RSQRB LPAR lines RPAR {
                                            $$ = new std::string("<img src=\"" + *$5 +"\" alt=\"" + *$2 + "\">");
                                            delete $2;
                                            delete $5;
                                            fprintf(fsyntax, "content -> IMGOPEN lines RSQRB LPAR lines RPAR\n");
                                          }
    ;

lines:
      line                       { $$ = $1; fprintf(fsyntax, "lines -> line\n"); }
    | lines line                 {
                                    $$ = new std::string(*$1 + *$2);
                                    delete $1;
                                    delete $2;
                                    fprintf(fsyntax, "lines -> lines line\n");
                                 }
    ;

line:
      TEXT                       { $$ = $1; fprintf(fsyntax, "line -> TEXT\n"); }
    | line TEXT                  {
                                    $$ = new std::string(*$1 + *$2);
                                    delete $1;
                                    delete $2;
                                    fprintf(fsyntax, "line -> line TEXT\n");
                                 }
    ;

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
