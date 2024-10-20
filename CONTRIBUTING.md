# Contributing to `markdown-transpiler`

Thank you for considering contributing to the `markdown-transpiler` project! Your involvement will help improve the project and expand its functionality. This document outlines the process for contributing, guidelines for submitting changes, and how you can help the project evolve.

## How to Contribute

### 1. Fork the Repository
Before making any changes, fork the repository to your own GitHub account. This will allow you to work on your own copy of the project.

### 2. Clone Your Fork
After forking the repository, clone it to your local machine:

```bash
git clone https://github.com/arya2004/markdown_transpiler.git
cd markdown-transpiler
```

### 3. Create a Branch
It's a good practice to create a new branch for every contribution you make. This helps keep your changes organized and isolated from other work.

```bash
git checkout -b my-feature-branch
```

Choose a branch name that describes the changes you are making.

### 4. Make Your Changes
Modify the codebase according to the change you are proposing. If you are contributing to specific functionality, you'll likely be working inside the `src/` directory. This might include:

- Updating the **Lex/Yacc** grammar rules to support new Markdown syntax.
- Enhancing or refactoring the **C++ code** that handles the Markdown to HTML conversion.
- Improving performance or fixing bugs.

### 5. Write Tests
If you add new functionality or fix a bug, please add tests to ensure the code behaves as expected. This will help maintain code quality and prevent future issues.

### 6. Build and Test Locally
Before submitting your contribution, make sure the project builds and works as expected. To compile and run the project:

1. Create a `build` directory and compile the project:
   ```bash
   mkdir build
   cd build
   cmake ..
   make
   ```

2. Run the transpiler:
   ```bash
   ./markdown2html input.md output.html
   ```

3. Ensure all tests pass. If you added any test Markdown files, verify they are converted to HTML correctly.

### 7. Commit Your Changes
Once you're happy with your changes, commit them. Be sure to write a clear and descriptive commit message.

```bash
git add .
git commit -m "Add support for XYZ Markdown feature"
```

### 8. Push to Your Fork
Push the changes from your local branch to your forked repository:

```bash
git push origin my-feature-branch
```

### 9. Open a Pull Request
Once your changes are pushed, open a pull request from your forked repository to the main repository. Navigate to the original repository on GitHub and click the **New Pull Request** button. 

In your pull request, include:
- A clear title and description of the changes you've made.
- Any relevant issues or feature requests that your pull request addresses.

### 10. Respond to Feedback
Be prepared to receive feedback from the maintainers. Review comments and make any necessary changes. Your pull request may go through several rounds of review before it is merged.

## Coding Guidelines

To maintain consistency across the project, please adhere to the following guidelines:

- **Code style**: Follow standard C++ conventions (e.g., proper indentation, meaningful variable names).
- **Lex/Yacc grammar**: Ensure any changes to the grammar files are tested thoroughly.
- **Modularity**: Keep functions and methods focused on a single task. Aim for clarity and simplicity.
- **Documentation**: Document any new features or functionality in the code as comments or additional Markdown files.

## Bug Reports and Feature Requests

If you find a bug or have a feature request, please open an issue on GitHub. Be sure to provide as much detail as possible, including:

- Steps to reproduce the issue.
- Expected and actual results.
- Any relevant logs or error messages.
  
For feature requests, describe the use case and how the feature would improve the project.

## Thank You

Your contributions are invaluable to the success of `markdown-transpiler`. Thank you for your time and effort in helping make this project better!

