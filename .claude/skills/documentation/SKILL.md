---
name: documentation
description: Create comprehensive documentation including README files, API documentation, inline code comments, tutorials, and technical guides. Use when asked to document, write docs, create README, or explain code.
---

# Documentation Expert

You are creating clear, comprehensive, and user-friendly documentation. Follow these guidelines to produce high-quality documentation.

## Documentation Philosophy

### Core Principles
- **Clarity**: Write for your audience's level of expertise
- **Completeness**: Cover all necessary information
- **Accuracy**: Ensure all information is correct and up-to-date
- **Examples**: Show practical usage with real examples
- **Maintainability**: Structure docs for easy updates

### Audience Considerations
- **Who**: Developers, end-users, maintainers, or stakeholders?
- **Knowledge Level**: Beginners, intermediate, or experts?
- **Goal**: What do they want to accomplish?

## Types of Documentation

### 1. README Files

**Essential Sections**:

```markdown
# Project Name

Brief description of what the project does (1-2 sentences).

## Features
- Key feature 1
- Key feature 2
- Key feature 3

## Installation

```bash
npm install project-name
```

## Quick Start

```javascript
const project = require('project-name');

// Basic usage example
project.doSomething();
```

## Usage

### Basic Example
Detailed example with explanation...

### Advanced Features
More complex usage patterns...

## API Reference
Link to detailed API docs or brief overview

## Configuration
How to configure the project...

## Contributing
Guidelines for contributors...

## License
License information...

## Support
How to get help...
```

**Best Practices**:
- Start with a clear, concise description
- Include badges (build status, version, coverage) if relevant
- Provide working examples that users can copy-paste
- Keep installation instructions simple and accurate
- Link to more detailed documentation when needed

### 2. API Documentation

For each API endpoint or function:

```markdown
## functionName(param1, param2, options)

Brief description of what the function does.

### Parameters
- `param1` (string, required): Description of param1
- `param2` (number, optional): Description of param2, default: 0
- `options` (object, optional): Configuration options
  - `option1` (boolean): Description of option1
  - `option2` (string): Description of option2

### Returns
`Promise<Result>`: Description of return value

### Throws
- `TypeError`: When param1 is not a string
- `RangeError`: When param2 is negative

### Example

```javascript
const result = await functionName('test', 42, {
  option1: true,
  option2: 'value'
});

console.log(result);
// Output: { status: 'success', data: ... }
```

### Notes
- Additional important information
- Performance considerations
- Version information
```

**API Documentation Structure**:
- **Clear signatures**: Show all parameters and types
- **Parameter details**: Type, required/optional, defaults
- **Return values**: What does it return?
- **Error conditions**: What can go wrong?
- **Examples**: Real-world usage
- **Version notes**: When was it added/deprecated?

### 3. Inline Code Comments

**When to Comment**:
- **Why, not what**: Explain the reasoning, not the obvious
- **Complex logic**: Clarify non-obvious algorithms
- **Business rules**: Document domain-specific requirements
- **TODOs and FIXMEs**: Note future work needed
- **Warnings**: Highlight gotchas or important constraints

**Good Comments**:
```javascript
// Calculate discount based on customer tier (Business Rule BR-2023-05)
// Premium customers get 20%, Standard get 10%, others get 5%
const discount = calculateTierDiscount(customer.tier);

// HACK: Third-party API doesn't handle timezone correctly,
// so we convert to UTC first. Remove when API v2 is released.
const utcDate = convertToUTC(localDate);

// Performance: Using binary search instead of linear search
// because the array is always sorted (see DataProcessor.sort())
const index = binarySearch(sortedArray, target);
```

**Bad Comments**:
```javascript
// Increment i
i++;

// Get user
const user = getUser();

// This function adds two numbers
function add(a, b) {
  return a + b;
}
```

**JSDoc/Docstring Style**:

JavaScript:
```javascript
/**
 * Processes a payment transaction
 *
 * @param {string} userId - The ID of the user making the payment
 * @param {number} amount - Payment amount in cents
 * @param {Object} options - Additional options
 * @param {string} options.currency - Currency code (default: 'USD')
 * @param {string} options.method - Payment method
 * @returns {Promise<Transaction>} The completed transaction
 * @throws {PaymentError} If payment processing fails
 *
 * @example
 * const transaction = await processPayment('user123', 5000, {
 *   currency: 'USD',
 *   method: 'credit_card'
 * });
 */
async function processPayment(userId, amount, options) {
  // Implementation
}
```

Python:
```python
def process_payment(user_id: str, amount: int, currency: str = 'USD') -> Transaction:
    """
    Process a payment transaction.

    Args:
        user_id: The ID of the user making the payment
        amount: Payment amount in cents
        currency: Currency code (default: 'USD')

    Returns:
        The completed transaction object

    Raises:
        PaymentError: If payment processing fails
        ValueError: If amount is negative

    Example:
        >>> transaction = process_payment('user123', 5000)
        >>> print(transaction.status)
        'completed'
    """
    # Implementation
```

### 4. Architecture Documentation

**High-Level Overview**:
```markdown
# Architecture Overview

## System Components

### Frontend
- Technology: React + TypeScript
- Responsibilities: User interface, client-side validation
- Communication: REST API calls to backend

### Backend
- Technology: Node.js + Express
- Responsibilities: Business logic, data validation, authentication
- Communication: PostgreSQL for data, Redis for caching

### Database
- Technology: PostgreSQL 14
- Schema: Normalized relational design
- Backup: Daily automated backups

## Data Flow

1. User submits form in Frontend
2. Frontend validates and sends to Backend API
3. Backend authenticates request
4. Backend processes business logic
5. Backend stores data in Database
6. Response returned to Frontend
7. Frontend updates UI

## Key Decisions

### Why React?
- Component reusability
- Large ecosystem
- Team expertise

### Why PostgreSQL?
- ACID compliance needed for transactions
- Complex relational queries
- Proven reliability
```

### 5. Tutorial/How-To Guides

**Structure**:
```markdown
# How to [Accomplish Task]

## Prerequisites
- Requirement 1
- Requirement 2

## Step 1: [First Step]
Explanation of what we're doing and why...

```bash
command to run
```

Expected output:
```
output you should see
```

## Step 2: [Second Step]
Continue with clear, numbered steps...

## Verification
How to verify it worked:
```bash
verification command
```

## Troubleshooting

### Issue 1: [Problem Description]
**Symptom**: What the user sees
**Cause**: Why it happens
**Solution**: How to fix it

## Next Steps
- What to explore next
- Links to related guides
```

### 6. Changelog

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- New feature in development

## [1.2.0] - 2025-01-15
### Added
- New authentication method
- Support for OAuth providers

### Changed
- Improved error messages
- Updated dependencies

### Deprecated
- Old authentication method (will be removed in 2.0.0)

### Fixed
- Bug in user registration
- Memory leak in background job

### Security
- Patched XSS vulnerability in user input
```

## Documentation Standards

### Writing Style

**Do**:
- Use active voice: "The function returns..." not "The value is returned..."
- Use present tense: "The API sends..." not "The API will send..."
- Be concise: Remove unnecessary words
- Use examples: Show, don't just tell
- Be consistent: Use same terminology throughout

**Don't**:
- Use jargon without explanation
- Assume knowledge the audience doesn't have
- Write overly long sentences
- Use ambiguous pronouns (it, this, that)

### Code Examples

**Requirements**:
- **Runnable**: Examples should work when copied
- **Complete**: Include all necessary imports and setup
- **Realistic**: Use realistic data and scenarios
- **Commented**: Explain non-obvious parts
- **Tested**: Verify examples actually work

**Template**:
```javascript
// Import required modules
const { ServiceName } = require('package-name');

// Initialize service
const service = new ServiceName({
  apiKey: 'your-api-key'
});

// Perform operation
async function example() {
  try {
    // Main operation with explanation
    const result = await service.doSomething({
      param: 'value'
    });

    // Show the result
    console.log('Success:', result);
  } catch (error) {
    // Handle errors
    console.error('Error:', error.message);
  }
}

// Run the example
example();
```

### Markdown Best Practices

- Use headers hierarchically (h1 -> h2 -> h3)
- Use code blocks with language identifiers: ```javascript
- Use tables for structured data
- Use lists for multiple items
- Use emphasis sparingly (**bold** for important, *italic* for emphasis)
- Include table of contents for long documents
- Link to related sections and external resources

## Documentation Checklist

Before finalizing documentation:

- [ ] Audience and purpose are clear
- [ ] All code examples are tested and work
- [ ] Links are valid and not broken
- [ ] Spelling and grammar are correct
- [ ] Technical terms are explained or linked
- [ ] Version information is included
- [ ] Table of contents is present (for long docs)
- [ ] Prerequisites are clearly stated
- [ ] Error cases and troubleshooting included
- [ ] Consistent formatting and style
- [ ] Screenshots/diagrams included where helpful
- [ ] Contact or support information provided

## Common Documentation Types by Project

### Library/Package
- README with installation and quick start
- API reference for all public functions
- Examples for common use cases
- Contributing guide
- Changelog

### Application
- README with overview and setup
- User guide/manual
- Architecture documentation
- Deployment guide
- Troubleshooting guide

### API Service
- API reference with all endpoints
- Authentication guide
- Rate limiting and quotas
- Error codes and handling
- Webhook documentation (if applicable)

## Tools to Use

- **Read**: Examine code to document
- **Write**: Create documentation files
- **Glob**: Find related files to include in docs
- **Grep**: Search for usage patterns to document
- **Bash**: Generate documentation from code (JSDoc, Sphinx, etc.)

## Output Format

When creating documentation, provide:

1. **File path**: Where to save the documentation
2. **Complete content**: Full, formatted documentation
3. **Related files**: Any additional docs or examples needed
4. **Maintenance notes**: How to keep docs updated

## Special Considerations

### Version Management
- Note which version features were added
- Mark deprecated features clearly
- Maintain migration guides for major versions

### Internationalization
- Use simple, clear English
- Avoid idioms and cultural references
- Consider providing i18n versions for major docs

### Accessibility
- Use descriptive link text (not "click here")
- Include alt text for images
- Ensure code examples are screen-reader friendly
- Use semantic markdown headers

## Remember

- Documentation is for humans, make it friendly
- Examples are worth a thousand words
- Keep docs updated with code changes
- Test all examples before publishing
- Link generously to related content
- Write docs you would want to read

---

**Version**: 1.0
**Last Updated**: 2025-01-01