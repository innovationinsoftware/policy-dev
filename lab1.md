### HashiCorp Sentinel Fundamentals Lab

#### Part 1: Verify Sentinel CLI

1. **Check Sentinel is installed:**
   - Run:
     ```bash
     sentinel version
     ```
   - _What version do you see?_

2. **Explore CLI help:**
   - Run:
     ```bash
     sentinel --help
     ```
   - _List two subcommands you see in the output._

3. **List available commands:**
   - Run:
     ```bash
     sentinel list
     ```
   - _What is the output?_

---

#### Part 2: Sentinel Language Basics

a. **Syntax and Structure**

4. **Create a minimal policy file:**
   - Create a file named `hello.sentinel` with this content:
     ```hcl
     main = rule { true }
     ```
   - Run:
     ```bash
     sentinel apply hello.sentinel
     ```
   - _What is the result?_

b. **Rules and Functions**

5. **Experiment with rules:**
   - Change `main = rule { true }` to `main = rule { false }` in `hello.sentinel`.
   - Run the apply command again.
   - _What changed in the output?_

6. **Try a function:**
   - Edit `hello.sentinel` to:
     ```hcl
     double = func(x) { x * 2 }
     main = rule { double(2) is 4 }
     ```
   - Run:
     ```bash
     sentinel apply hello.sentinel
     ```
   - _Does the policy pass?_

---

c. **Imports and Modules**

7. **Use a built-in import:**
   - Create a file `import-test.sentinel`:
     ```hcl
     import "strings"
     main = rule { strings.has_prefix("sentinel", "sen") }
     ```
   - Run:
     ```bash
     sentinel apply import-test.sentinel
     ```
   - _What is the result?_

---

#### Part 3: CLI Options Practice

8. **Try the trace flag:**
   - Run:
     ```bash
     sentinel apply import-test.sentinel -trace
     ```
   - _What extra information do you see?_

9. **Explore more help:**
   - Run:
     ```bash
     sentinel apply --help
     ```
   - _Name one option you find useful._

---

### Lab Completion

You have:
- Verified Sentinel CLI installation
- Explored CLI commands and help
- Practiced Sentinel syntax, rules, functions, and imports interactively
- Used CLI options for more insight

_You are now ready for more advanced Sentinel labs!_
