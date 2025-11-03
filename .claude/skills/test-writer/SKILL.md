---
name: test-writer
description: Generate comprehensive test suites including unit tests, integration tests, and end-to-end tests. Use when asked to write, create, or generate tests, test cases, or test coverage.
---

# Test Writer Expert

You are generating comprehensive, well-structured tests. Follow these guidelines to create high-quality test suites.

## Testing Philosophy

### Core Principles
- **Comprehensive Coverage**: Test all code paths, edge cases, and error conditions
- **Clear & Maintainable**: Tests should be easy to read and understand
- **Fast & Reliable**: Tests should run quickly and consistently
- **Independent**: Each test should be isolated and not depend on others
- **Descriptive**: Test names should clearly describe what they're testing

## Test Creation Process

### 1. Analyze the Code
- **Read the code** thoroughly to understand its functionality
- **Identify dependencies**: External services, databases, file systems
- **List functions/methods**: What needs to be tested?
- **Note edge cases**: Boundary conditions, error scenarios, special inputs

### 2. Determine Test Strategy
- **Unit Tests**: Test individual functions/methods in isolation
- **Integration Tests**: Test interactions between components
- **End-to-End Tests**: Test complete user workflows
- **Property-Based Tests**: Test with generated inputs (when applicable)

### 3. Plan Test Cases
For each function/method, create tests for:
- **Happy path**: Normal, expected usage
- **Edge cases**: Boundary values, empty inputs, large inputs
- **Error cases**: Invalid inputs, missing dependencies, exceptions
- **State changes**: Verify state before and after operations

### 4. Write Tests
Follow the **Arrange-Act-Assert** pattern:
```
// Arrange: Set up test data and conditions
// Act: Execute the function being tested
// Assert: Verify the results
```

## Test Structure by Language

### JavaScript/TypeScript (Jest, Vitest, Mocha)
```javascript
describe('FunctionName', () => {
  describe('when given valid input', () => {
    it('should return expected result', () => {
      // Arrange
      const input = 'test';

      // Act
      const result = functionName(input);

      // Assert
      expect(result).toBe('expected');
    });
  });

  describe('when given invalid input', () => {
    it('should throw an error', () => {
      expect(() => functionName(null)).toThrow();
    });
  });
});
```

### Python (pytest, unittest)
```python
class TestFunctionName:
    def test_valid_input_returns_expected_result(self):
        # Arrange
        input_data = "test"

        # Act
        result = function_name(input_data)

        # Assert
        assert result == "expected"

    def test_invalid_input_raises_error(self):
        with pytest.raises(ValueError):
            function_name(None)
```

### Java (JUnit)
```java
class FunctionNameTest {
    @Test
    void shouldReturnExpectedResultForValidInput() {
        // Arrange
        String input = "test";

        // Act
        String result = functionName(input);

        // Assert
        assertEquals("expected", result);
    }

    @Test
    void shouldThrowExceptionForInvalidInput() {
        assertThrows(IllegalArgumentException.class,
            () -> functionName(null));
    }
}
```

### Go
```go
func TestFunctionName(t *testing.T) {
    t.Run("returns expected result for valid input", func(t *testing.T) {
        // Arrange
        input := "test"

        // Act
        result := FunctionName(input)

        // Assert
        if result != "expected" {
            t.Errorf("got %v, want %v", result, "expected")
        }
    })
}
```

## Testing Patterns

### Mocking and Stubbing
When code has external dependencies:

```javascript
// Mock external API
jest.mock('./api-client');
const apiClient = require('./api-client');

test('fetches user data', async () => {
  apiClient.getUser.mockResolvedValue({ id: 1, name: 'John' });

  const result = await fetchUserData(1);

  expect(result.name).toBe('John');
  expect(apiClient.getUser).toHaveBeenCalledWith(1);
});
```

### Test Fixtures
Reusable test data:

```python
@pytest.fixture
def sample_user():
    return {
        'id': 1,
        'name': 'John Doe',
        'email': 'john@example.com'
    }

def test_process_user(sample_user):
    result = process_user(sample_user)
    assert result['id'] == 1
```

### Parameterized Tests
Test multiple inputs efficiently:

```python
@pytest.mark.parametrize("input,expected", [
    (0, 0),
    (1, 1),
    (2, 4),
    (3, 9),
    (-1, 1),
])
def test_square(input, expected):
    assert square(input) == expected
```

## Coverage Guidelines

### What to Test

**Always Test**:
- Public API methods and functions
- Business logic and calculations
- Error handling and validation
- State changes and side effects
- Integration points

**Consider Testing**:
- Private methods if they contain complex logic
- Utility functions
- Edge cases specific to your domain

**Don't Test**:
- Third-party library internals
- Trivial getters/setters (unless they have logic)
- Framework code

### Edge Cases to Consider

- **Null/Undefined/None**: How does code handle missing values?
- **Empty collections**: Arrays, strings, objects, lists
- **Boundary values**: 0, -1, MAX_INT, empty string
- **Large inputs**: Performance with big data sets
- **Concurrent access**: Thread safety, race conditions
- **Network failures**: Timeouts, disconnections
- **Invalid types**: Wrong data types passed in

## Test Organization

### File Structure
```
src/
  user-service.js
tests/
  unit/
    user-service.test.js
  integration/
    user-api.test.js
  e2e/
    user-flow.test.js
```

### Naming Conventions

**Test Files**:
- `<module>.test.js` or `<module>.spec.js`
- `test_<module>.py`

**Test Names** (should be descriptive):
- `should return user when valid ID provided`
- `test_raises_error_when_user_not_found`
- `shouldCalculateTotalWithTaxCorrectly`

## Test Quality Checklist

- [ ] Tests are independent and can run in any order
- [ ] Each test has a clear, descriptive name
- [ ] Tests follow Arrange-Act-Assert pattern
- [ ] Edge cases and error conditions are covered
- [ ] Mocks/stubs are used appropriately for external dependencies
- [ ] Tests are fast (no unnecessary waits or delays)
- [ ] Assertions are specific and meaningful
- [ ] Test data is realistic and representative
- [ ] Cleanup is performed after tests (if needed)
- [ ] Tests document the expected behavior

## Integration Testing

When testing multiple components together:

```javascript
describe('User Registration Flow', () => {
  let database;
  let emailService;

  beforeEach(async () => {
    database = await setupTestDatabase();
    emailService = createMockEmailService();
  });

  afterEach(async () => {
    await cleanupTestDatabase(database);
  });

  it('should create user and send welcome email', async () => {
    const userData = { email: 'test@example.com', name: 'Test' };

    const user = await registerUser(userData, database, emailService);

    expect(user.id).toBeDefined();
    expect(emailService.sendWelcomeEmail).toHaveBeenCalledWith(userData.email);
  });
});
```

## Test Doubles

### Mock
Verifies interactions (calls, arguments):
```javascript
const mockLogger = { log: jest.fn() };
service.process(data, mockLogger);
expect(mockLogger.log).toHaveBeenCalledWith('Processing complete');
```

### Stub
Provides predetermined responses:
```javascript
const stubApi = { fetchData: () => Promise.resolve({ data: 'test' }) };
```

### Spy
Wraps real object to observe interactions:
```javascript
const spy = jest.spyOn(object, 'method');
```

## Performance Testing

For performance-critical code:

```javascript
test('processes large dataset efficiently', () => {
  const largeDataset = generateData(10000);
  const startTime = performance.now();

  processData(largeDataset);

  const duration = performance.now() - startTime;
  expect(duration).toBeLessThan(1000); // Should complete in under 1 second
});
```

## Output Format

When generating tests, provide:

1. **Test file path**: Where the test should be saved
2. **Test code**: Complete, runnable test suite
3. **Setup instructions**: Any dependencies or configuration needed
4. **Coverage summary**: What scenarios are covered

## Best Practices

- **Write tests first** (TDD) when possible
- **Keep tests simple**: One concept per test
- **Use descriptive names**: Test name should explain what and why
- **Avoid test interdependence**: Each test should be runnable independently
- **Test behavior, not implementation**: Focus on what, not how
- **Keep tests DRY**: Use setup/teardown and helpers for common code
- **Make failures clear**: Assertions should clearly indicate what went wrong
- **Update tests with code**: Tests should evolve with the codebase

## Tools to Use

- **Read**: Examine the code to be tested
- **Write**: Create test files
- **Bash**: Run tests to verify they work
- **Glob**: Find related test files for reference
- **Grep**: Search for existing test patterns

## Remember

- Tests are documentation of how code should behave
- Good tests make refactoring safe and easy
- Aim for high coverage but prioritize meaningful tests over 100% coverage
- Test the behavior users care about, not just code coverage metrics

---

**Version**: 1.0
**Last Updated**: 2025-01-01