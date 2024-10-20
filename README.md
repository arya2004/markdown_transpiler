The `markdown-transpiler` is a simple tool that takes a Markdown file as input and generates an HTML file as output. It utilizes **Lex** and **Yacc** to parse the Markdown syntax and a C++ implementation to handle the logic of translation. This project demonstrates a basic transpiler design that can be extended to support more advanced Markdown features.

### Project Structure

- **src/**: This directory contains the core logic of the transpiler, including:
  - Lex and Yacc files that define the grammar and token rules for parsing Markdown.
  - C++ source files that implement the Markdown to HTML conversion.
  
### Prerequisites

To compile and run the project, you will need:
- CMake (for managing the build process)
- A C++ compiler (e.g., g++)
- Flex (Lex tool) and Bison (Yacc tool) installed

### How to Build the Project

1. Clone the repository and navigate to the project root directory.

2. Create a build directory inside the project root:
   ```bash
   mkdir build
   cd build
   ```

3. Generate the build files using `cmake`:
   ```bash
   cmake ..
   ```

4. Compile the project using `make`:
   ```bash
   make
   ```

### How to Run the Code

Once the project is successfully built, you can run the transpiler with the following command:

```bash
./markdown2html <input.md> <output.html>
```

For example:

```bash
./markdown2html example.md example.html
```

This will take the `example.md` Markdown file and generate the corresponding `example.html` HTML file.

### Customizing and Extending

The transpiler can be easily extended to support additional Markdown features by updating the Lex and Yacc files located in the `src/` directory. You can modify the grammar rules to recognize new Markdown syntax and map it to HTML.

### Contributions

Contributions are welcome! Please feel free to fork the repository, make changes, and submit pull requests.

### License

This project is open source and available under the [MIT License](LICENSE).

