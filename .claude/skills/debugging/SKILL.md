---
name: debugging
description: Systematically diagnose and fix bugs, errors, and unexpected behavior. Use when asked to debug, fix bugs, troubleshoot errors, or investigate issues.
---

# Debugging Expert

You are systematically diagnosing and fixing bugs. Follow this structured approach to efficiently identify and resolve issues.

## Debugging Philosophy

### Core Principles
- **Reproduce First**: Ensure you can consistently reproduce the bug
- **Scientific Method**: Form hypotheses, test them, gather evidence
- **Systematic Approach**: Work methodically, not randomly
- **Understand Before Fixing**: Know why it's broken before changing code
- **Test the Fix**: Verify the bug is actually fixed

## The Debugging Process

### 1. Understand the Problem

**Gather Information**:
- What is the expected behavior?
- What is the actual behavior?
- When does it happen? (always, sometimes, specific conditions)
- Error messages or stack traces
- Recent changes to the codebase

**Questions to Ask**:
- Can you reproduce it consistently?
- Does it happen in all environments or just some?
- What are the exact steps to reproduce?
- What input causes the problem?
- When did it start happening?

### 2. Reproduce the Bug

**Create a Minimal Reproduction**:
- Isolate the smallest code sample that exhibits the bug
- Remove unrelated code and dependencies
- Document exact steps to reproduce
- Note environment details (OS, versions, config)

**Test Cases**:
```javascript
// Create a test that fails due to the bug
test('should handle edge case', () => {
  const result = buggyFunction(edgeCaseInput);
  expect(result).toBe(expectedOutput); // This fails
});
```

### 3. Locate the Bug

**Techniques**:

**Binary Search**:
- Comment out half the code
- Narrow down which half contains the bug
- Repeat until you find the problematic line

**Logging/Print Debugging**:
```javascript
console.log('Before calculation:', { x, y, z });
const result = calculate(x, y, z);
console.log('After calculation:', { result });
console.log('Expected:', expectedResult);
```

**Debugger**:
- Set breakpoints at suspected locations
- Step through code line by line
- Inspect variable values at each step
- Watch expressions to track state changes

**Stack Trace Analysis**:
```
Error: Cannot read property 'name' of undefined
  at getUserName (user-service.js:45)
  at processUser (user-processor.js:23)
  at handleRequest (api-handler.js:12)
```
Work backwards from the error location.

**Git Bisect**:
```bash
git bisect start
git bisect bad  # Current version is bad
git bisect good v1.2.0  # This version was good
# Git will check out commits for testing
# Mark each as good or bad until the problematic commit is found
```

### 4. Form Hypotheses

Based on the symptoms, create testable hypotheses:

**Example Hypotheses**:
- "The function fails when the input array is empty"
- "The race condition occurs when two requests arrive simultaneously"
- "The memory leak is caused by event listeners not being cleaned up"
- "The null error happens because the API returns null instead of an empty object"

**Test Each Hypothesis**:
```javascript
// Hypothesis: Function fails with empty array
console.log('Testing with empty array...');
const result = functionName([]);
console.log('Result:', result);  // Does it fail?

// Hypothesis: Function fails with null
console.log('Testing with null...');
const result2 = functionName(null);
console.log('Result:', result2);  // Does it fail?
```

### 5. Analyze Root Cause

**Common Bug Categories**:

**Logic Errors**:
- Off-by-one errors: `for (i = 0; i <= arr.length; i++)` should be `i < arr.length`
- Incorrect conditions: `if (x = 5)` instead of `if (x === 5)`
- Wrong operator: `&&` instead of `||`
- Missing edge case handling

**State Management**:
- Stale closures capturing old values
- Shared mutable state between components
- Missing state updates
- Race conditions in async operations

**Type Issues**:
- Undefined vs null confusion
- Type coercion: `"5" + 5 = "55"` not `10`
- NaN propagation in calculations
- Truthy/falsy misunderstanding

**Async Issues**:
- Not awaiting promises
- Missing error handling in promises
- Race conditions
- Callback hell
- Unhandled promise rejections

**Memory Issues**:
- Memory leaks from unreleased references
- Circular references
- Event listeners not cleaned up
- Growing arrays/caches without limits

**Scope & Context**:
- `this` binding issues
- Closure capture problems
- Variable shadowing
- Hoisting confusion

### 6. Implement the Fix

**Before Fixing**:
- Write a failing test that captures the bug
- Understand the root cause completely
- Consider side effects of the fix
- Think about similar bugs elsewhere

**Fix Strategies**:

**Null/Undefined Check**:
```javascript
// Before (buggy)
function getUserName(user) {
  return user.name;  // Fails if user is null
}

// After (fixed)
function getUserName(user) {
  if (!user) {
    return 'Anonymous';
  }
  return user.name ?? 'Anonymous';
}
```

**Edge Case Handling**:
```javascript
// Before (buggy)
function getAverage(numbers) {
  return numbers.reduce((a, b) => a + b) / numbers.length;
}

// After (fixed)
function getAverage(numbers) {
  if (!Array.isArray(numbers) || numbers.length === 0) {
    return 0;
  }
  return numbers.reduce((a, b) => a + b, 0) / numbers.length;
}
```

**Async Fix**:
```javascript
// Before (buggy)
async function loadData() {
  const data = fetchData();  // Missing await
  return data.items;  // data is a Promise, not the actual data
}

// After (fixed)
async function loadData() {
  const data = await fetchData();
  return data.items;
}
```

**Race Condition Fix**:
```javascript
// Before (buggy)
let requestId = 0;
async function search(query) {
  requestId++;
  const results = await api.search(query);
  displayResults(results);  // May display old results
}

// After (fixed)
let requestId = 0;
async function search(query) {
  const currentRequestId = ++requestId;
  const results = await api.search(query);
  if (currentRequestId === requestId) {  // Only use if still latest
    displayResults(results);
  }
}
```

### 7. Verify the Fix

**Testing Checklist**:
- [ ] Original bug is fixed
- [ ] Test case passes
- [ ] No new bugs introduced
- [ ] Edge cases still work
- [ ] Performance not degraded
- [ ] Similar code paths checked

**Regression Testing**:
```bash
# Run full test suite
npm test

# Test in different environments
npm run test:integration
npm run test:e2e

# Manual testing
# Test the specific bug scenario
# Test related functionality
# Test edge cases
```

### 8. Prevent Future Bugs

**Add Tests**:
```javascript
describe('getUserName', () => {
  it('should handle null user', () => {
    expect(getUserName(null)).toBe('Anonymous');
  });

  it('should handle user without name', () => {
    expect(getUserName({})).toBe('Anonymous');
  });

  it('should return user name when present', () => {
    expect(getUserName({ name: 'John' })).toBe('John');
  });
});
```

**Add Defensive Code**:
- Input validation
- Type checking (TypeScript, PropTypes)
- Assertions
- Error boundaries

**Document Gotchas**:
```javascript
/**
 * IMPORTANT: This function expects the data array to be sorted.
 * If unsorted, results will be incorrect.
 * See bug #123 for details.
 */
function binarySearch(sortedData, target) {
  // Implementation
}
```

## Debugging Tools by Language

### JavaScript/TypeScript
- **Console methods**: `console.log()`, `console.table()`, `console.trace()`
- **Debugger statement**: `debugger;`
- **Browser DevTools**: Breakpoints, watch expressions, call stack
- **Node.js debugger**: `node --inspect`
- **Chrome DevTools**: Network tab, Performance profiler

### Python
- **pdb**: `import pdb; pdb.set_trace()`
- **Print debugging**: `print(f"Variable: {variable}")`
- **Logging**: `logging.debug()`, `logging.info()`
- **IDE debuggers**: PyCharm, VS Code Python debugger

### Java
- **System.out**: `System.out.println()`
- **Logger**: `logger.debug()`, `logger.error()`
- **IDE debuggers**: IntelliJ, Eclipse debugger
- **JDB**: Command-line debugger

### Go
- **fmt.Println**: `fmt.Printf("Value: %+v\n", value)`
- **Delve**: `dlv debug`
- **IDE integration**: VS Code, GoLand

## Common Bug Patterns

### 1. The Heisenbug
Bug that disappears when you try to debug it.
**Cause**: Often timing-related or affected by debugging overhead
**Solution**: Use logging instead of breakpoints, add delays to investigate timing

### 2. The Bohrbug
Bug that manifests consistently under well-defined conditions.
**Cause**: Logic error, missing validation
**Solution**: Standard debugging process, add test coverage

### 3. The Mandelbug
Bug with such complex causes that it appears chaotic.
**Cause**: Multiple interacting factors, complex state
**Solution**: Simplify, isolate components, use systematic approach

### 4. The Schroedinbug
Bug that appears after someone reads code and realizes it shouldn't work.
**Cause**: Incorrect code that happened to work by accident
**Solution**: Fix properly, add tests

## Debugging Checklist

When stuck, try these:

- [ ] Read the error message carefully (every word)
- [ ] Check the stack trace for the actual error location
- [ ] Verify your assumptions (print/log values)
- [ ] Search for the error message online
- [ ] Check recent changes (git diff, git log)
- [ ] Reproduce in a minimal example
- [ ] Take a break and come back fresh
- [ ] Explain the bug to someone else (rubber duck debugging)
- [ ] Check documentation for the library/framework
- [ ] Verify environment (versions, config, environment variables)
- [ ] Check for known issues in the project's issue tracker

## Advanced Techniques

### Time-Travel Debugging
Use tools like Redux DevTools, rr (record and replay) to step backwards through execution.

### Heap Dump Analysis
For memory leaks:
```bash
# Node.js
node --inspect --heap-prof app.js
# Analyze heap snapshot in Chrome DevTools
```

### Performance Profiling
For performance bugs:
```javascript
console.time('operation');
performOperation();
console.timeEnd('operation');
```

### Network Debugging
For API issues:
- Use browser DevTools Network tab
- Use curl/httpie for CLI testing
- Use tools like Postman
- Check CORS, headers, request/response bodies

## Tools to Use

- **Read**: Examine the buggy code
- **Bash**: Run tests, execute debugging commands
- **Edit**: Implement fixes
- **Grep**: Search for similar code patterns
- **Glob**: Find related files

## Output Format

When debugging, provide:

1. **Problem Analysis**: What is the bug?
2. **Root Cause**: Why does it happen?
3. **Fix**: The code changes needed
4. **Verification**: How to confirm it's fixed
5. **Prevention**: Tests or changes to prevent recurrence

## Remember

- Debugging is a skill that improves with practice
- Stay systematic, avoid random changes
- Document what you learn
- Every bug is an opportunity to improve the codebase
- Sometimes the bug is in your understanding, not the code

---

**Version**: 1.0
**Last Updated**: 2025-01-01