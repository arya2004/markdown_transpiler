#include "parser.hpp"
#include "lexer.hpp"
#include <cstdio>
#include <iostream>

extern int yylex(void);
extern int yyparse(void);

extern void init_lexer();
extern void close_lexer();
extern void init_parser();
extern void close_parser();
extern void write_semantic_output();

int main(int argc, char* argv[]){

    if(argc!=3){
        std::cout<<"Error USAGE: "<<argv[0]<<" <input.md> <output.html>\n";
        return 1;
    }

    const char* inputFilePath = argv[1];
    const char* outputFilePath = argv[2];

    FILE *fptrout , *fptrin;

    // opening input file in read mode
    fptrin = fopen(inputFilePath, "r");
  
    // checking if input file is opened successfully
    if (fptrin == NULL) {
        printf("Error: Unable to open MD File.\n");
        exit(0);
    }

    // opening the output file in write mode
    fptrout = fopen(outputFilePath, "w");
  
    // checking if output file is opened successfully
    if (fptrout == NULL) {
        printf("Error: Unable to open HTML File.\n");
        exit(0);
    }

    extern FILE *yyin;

    // mapping lexer input pointer to input file pointer
    yyin = fptrin;

    // Initialize lexer and parser
    init_lexer();
    init_parser();

    // writing html header content in output file
    fprintf(fptrout,"<!DOCTYPE html>\n");
    fprintf(fptrout,"<html>\n");
    fprintf(fptrout,"<head>\n");
    fprintf(fptrout,"\t<title>Title html</title>\n");
    fprintf(fptrout,"</head>\n");
    fprintf(fptrout,"<body>\n");

    std::string* outputHTML;
    // performing conversion from markdown to html tags
    yyparse();

    outputHTML = getHtmlOut();
    printf("%s\n", outputHTML->c_str());

    // writing html end file tags in the output file
    fprintf(fptrout,"%s\n", outputHTML->c_str());
    fprintf(fptrout,"</body>\n");
    fprintf(fptrout,"</html>");

    // Write semantic output
    write_semantic_output();

    fclose(fptrin);
    fclose(fptrout);

    // Close lexer and parser
    close_lexer();
    close_parser();

    return 0;
}
