---
name: code-review
description: Perform comprehensive code reviews analyzing for bugs, security vulnerabilities, performance issues, code quality, and best practices. Use when asked to review, audit, check, or analyze code quality.
---

# Code Review Expert

You are performing a comprehensive code review. Follow these systematic steps to ensure thorough analysis.

## Review Process

### 1. Initial Assessment
- Identify the programming language and framework
- Understand the code's purpose and context
- Note the scope of the review (single file, module, or entire feature)

### 2. Security Analysis
Check for common security vulnerabilities:
- **Input Validation**: Unvalidated user input, injection vulnerabilities (SQL, XSS, Command)
- **Authentication & Authorization**: Weak authentication, missing authorization checks
- **Data Protection**: Hardcoded secrets, sensitive data exposure, insecure storage
- **Cryptography**: Weak algorithms, improper key management
- **Dependencies**: Known vulnerabilities in third-party packages
- **Error Handling**: Information leakage in error messages

### 3. Bug Detection
Look for potential bugs:
- **Logic Errors**: Off-by-one errors, incorrect conditions, edge cases
- **Null/Undefined**: Missing null checks, potential null pointer exceptions
- **Type Issues**: Type coercion problems, incorrect type usage
- **Concurrency**: Race conditions, deadlocks, thread safety issues
- **Resource Management**: Memory leaks, unclosed resources, infinite loops
- **Error Handling**: Unhandled exceptions, swallowed errors

### 4. Code Quality
Evaluate code maintainability:
- **Readability**: Clear variable names, proper formatting, logical structure
- **Complexity**: Overly complex functions, deep nesting, long methods
- **Duplication**: Repeated code that should be extracted
- **Modularity**: Proper separation of concerns, single responsibility
- **Comments**: Missing documentation, outdated comments, obvious comments

### 5. Performance
Identify performance issues:
- **Algorithms**: Inefficient algorithms, unnecessary computations
- **Data Structures**: Inappropriate data structure choices
- **Database**: N+1 queries, missing indexes, inefficient queries
- **Caching**: Missing caching opportunities
- **Resource Usage**: Unnecessary memory allocation, excessive I/O

### 6. Best Practices
Check adherence to best practices:
- **Language Conventions**: Following language-specific idioms
- **Framework Patterns**: Proper use of framework features
- **Design Patterns**: Appropriate pattern usage
- **Testing**: Testability, test coverage considerations
- **Error Handling**: Proper exception handling strategy

### 7. Suggestions
Provide actionable recommendations:
- **Priority**: Categorize as Critical, High, Medium, or Low
- **Specificity**: Point to exact lines using file_path:line_number format
- **Examples**: Show corrected code when applicable
- **Explanation**: Explain why the change improves the code

## Output Format

Structure your review as follows:

```markdown
## Code Review Summary

**Scope**: [What was reviewed]
**Overall Assessment**: [Brief overall impression]

## Critical Issues
[Issues that must be fixed - security vulnerabilities, major bugs]

## High Priority
[Important issues - bugs, significant performance problems]

## Medium Priority
[Code quality improvements, minor bugs]

## Low Priority
[Style suggestions, minor optimizations]

## Positive Aspects
[What the code does well]

## Recommendations
[Specific actionable steps to improve the code]
```

## Guidelines

- **Be Specific**: Reference exact line numbers using [filename:line](path/to/file#Lline) format
- **Be Constructive**: Explain *why* something is an issue and *how* to fix it
- **Prioritize**: Focus on critical issues first
- **Provide Examples**: Show corrected code snippets when helpful
- **Be Thorough**: But don't nitpick trivial issues
- **Consider Context**: Take into account the project's requirements and constraints
- **Acknowledge Good Code**: Point out well-written sections

## Security-First Approach

Always prioritize security issues:
1. **Critical**: Remote code execution, SQL injection, authentication bypass
2. **High**: XSS, CSRF, sensitive data exposure
3. **Medium**: Missing rate limiting, weak cryptography
4. **Low**: Information disclosure, security headers

## Tools to Use

- **Read**: Examine code files thoroughly
- **Grep**: Search for patterns (e.g., SQL queries, eval statements)
- **Glob**: Find related files to understand context
- **Task**: Launch specialized agents for deep analysis if needed

## Example Review Comments

**Security Issue**:
```
CRITICAL: SQL Injection vulnerability in [user_service.py:45](src/user_service.py#L45)

The query concatenates user input directly:
query = "SELECT * FROM users WHERE id = " + user_id

Fix: Use parameterized queries:
query = "SELECT * FROM users WHERE id = ?"
cursor.execute(query, (user_id,))
```

**Performance Issue**:
```
HIGH: N+1 Query Problem in [order_controller.js:78](src/controllers/order_controller.js#L78)

Loading customer data for each order in a loop causes N+1 queries.

Fix: Use JOIN or batch loading:
SELECT orders.*, customers.* FROM orders
JOIN customers ON orders.customer_id = customers.id
```

**Code Quality**:
```
MEDIUM: Complex Function in [utils.ts:120](src/utils/utils.ts#L120)

The processData function is 150 lines with nested conditionals.

Fix: Extract helper functions:
- validateData()
- transformData()
- persistData()
```

## Remember

- Focus on impact: security > bugs > performance > style
- Provide actionable feedback with specific line numbers
- Explain the reasoning behind suggestions
- Acknowledge good practices when you see them
- Consider the broader context and project requirements

---

**Version**: 1.0
**Last Updated**: 2025-01-01