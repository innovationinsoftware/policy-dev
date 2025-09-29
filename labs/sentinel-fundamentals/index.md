# HashiCorp Sentinel Fundamentals Lab

## Overview
In this lab, you'll get hands-on experience with the HashiCorp Sentinel CLI and its language fundamentals. You'll learn how to verify your installation, explore the CLI, and understand the basics of Sentinel's syntax, rules, functions, and imports. This foundation will prepare you for writing and testing policies in real-world scenarios.

---

## Lab Setup

### Create a Working Directory

1. Open **Visual Studio Code**.
2. Click on **File** > **Open Folder...** and create a new folder in your Documents folder named `labs`.

### Create the Lab Directory

1. Right-click inside the VS Code **Explorer** pane and select **New Folder**.
2. Name this folder `lab1`.
3. Right-click the folder and click "Open in Integrated Terminal."

All commands and files in this lab should be created and run inside the `lab1` directory.

---

## Part 1: Getting Started with the Sentinel CLI

Before you can use Sentinel to enforce policies, ensure the CLI is installed and accessible. This section will help you confirm your setup and introduce you to the available commands.

### 1. Verify Sentinel Installation
Let's start by checking that Sentinel is installed and ready to use. Open your terminal and run:
```bash
sentinel version
```
You should see the version number printed. This confirms that the CLI is available on your system.

### 2. Explore the CLI Help
Sentinel provides a helpful built-in guide to its commands. To see what you can do with the CLI, run:
```bash
sentinel --help
```
Take a moment to look through the output. Notice the available subcommands and options. This is your reference for exploring Sentinel's capabilities.

---

## Part 2: Exploring Sentinel Language Basics

Now that you've seen the CLI, let's dive into the language itself. Sentinel policies are written in a simple, logic-based language. In this section, you'll create and run your first policies to see how Sentinel evaluates them.

### 4. Create and Run a Minimal Policy
A Sentinel policy is just a file with a `.sentinel` extension. Let's create the simplest possible policy:
1. In your `lab1` directory, create a new file called `hello.sentinel` with this content:
   ```hcl
   main = rule { true }
   ```
2. Run the policy:
   ```bash
   sentinel apply hello.sentinel
   ```
   You should see `PASS` as the result. This means the policy's main rule evaluated to true.

### 5. Experiment with Rules
Rules are the core of Sentinel policies. Let's see what happens when a rule fails:
1. Edit `hello.sentinel` and change `main = rule { true }` to `main = rule { false }`.
2. Run the policy again:
   ```bash
   sentinel apply hello.sentinel
   ```
   You should now see `FAIL`. This demonstrates how rules control policy outcomes.

### 6. Try a Function
Sentinel supports functions for reusable logic. Let's add a simple function to your policy:
1. Edit `hello.sentinel` to:
   ```hcl
   double = func(x) { return x * 2 }
   main = rule { double(2) is 4 }
   ```
2. Run:
   ```bash
   sentinel apply hello.sentinel
   ```
   You should see `PASS`. This shows how you can define and use functions in your policies.

---

## Part 3: Using Imports for More Power

Sentinel includes built-in imports (libraries) for common operations, such as string manipulation. Let's try one out.

### 7. Use a Built-in Import
1. Create a new file named `import-test.sentinel` in the `lab1` directory with this content:
   ```hcl
   import "strings"
   main = rule { strings.has_prefix("sentinel", "sen") }
   ```
2. Run:
   ```bash
   sentinel apply import-test.sentinel
   ```
   You should see `PASS`. This means the import worked and the rule evaluated as expected.

---

### 9. Formatting Policies with `sentinel fmt`

The Sentinel CLI provides a `fmt` command to automatically format your policy files to a canonical style. This helps keep your code clean and consistent.

1. In your `lab1` directory, create or edit a file called `messy.sentinel` with poorly formatted content, for example:
   ```hcl
   main=rule{true}
   ```

2. Format the file in place:
   ```bash
   sentinel fmt messy.sentinel
   ```
   The file will be rewritten in a clean, canonical format. Open `messy.sentinel` to see the result:
   ```hcl
   main = rule { true }
   ```

3. To check if a file needs formatting (without changing it):
   ```bash
   sentinel fmt -check=true messy.sentinel
   ```
   If the file is already formatted, there will be no output and the exit code will be 0. If not, the filename will be printed and the exit code will be non-zero.

4. To see the formatted output without modifying the file:
   ```bash
   sentinel fmt -write=false messy.sentinel
   ```
   The formatted policy will be printed to your terminal, but the file will not be changed.

Using `sentinel fmt` helps ensure your policies are easy to read and maintain.

---

### 10. Explore More Help
You can always get more information about any command or option. For example, to see all options for `apply`, run:
```bash
sentinel apply --help
```
Review the output and note any options you find useful for your workflow.

---

## Lab Completion

In this lab, you:
- Verified your Sentinel CLI installation
- Explored the CLI and its commands
- Practiced writing and running basic Sentinel policies
- Used imports for more advanced behavior
- Used the formatter to keep your policies clean

You now have a solid foundation for working with Sentinel. You're ready to move on to more advanced policy development and integration with HashiCorp tools!
