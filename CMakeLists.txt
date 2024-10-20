cmake_minimum_required(VERSION 3.10)

project(markdown_transpiler VERSION 1.0 LANGUAGES C CXX)

set(SRC_DIR "src")
set(OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}")

find_package(FLEX)
find_package(BISON)

set(LEXER_OUT "${OUTPUT_DIR}/lexer.cpp")
set(PARSER_OUT "${OUTPUT_DIR}/parser.cpp")

flex_target(LEXER "${SRC_DIR}/lexer.l" "${LEXER_OUT}" DEFINES_FILE "${OUTPUT_DIR}/lexer.hpp" )
bison_target(PARSER "${SRC_DIR}/parser.y" "${PARSER_OUT}" DEFINES_FILE "${OUTPUT_DIR}/parser.hpp")
add_flex_bison_dependency(LEXER PARSER)

add_executable(markdown_transpiler 
            "${PARSER_OUT}" 
            "${LEXER_OUT}" 
            "${SRC_DIR}/main.cpp")

target_include_directories(markdown_transpiler PRIVATE "${OUTPUT_DIR}")