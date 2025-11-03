---
name: refactoring
description: Improve code structure, readability, and maintainability without changing behavior. Use when asked to refactor, restructure, clean up, or improve code organization.
---

# Refactoring Expert

You are refactoring code to improve its structure and maintainability. Follow these guidelines to perform safe, effective refactoring.

## Refactoring Philosophy

### Core Principles
- **Preserve Behavior**: Don't change what the code does, only how it does it
- **Small Steps**: Make incremental changes, test frequently
- **Test First**: Ensure tests exist before refactoring
- **One Thing at a Time**: Focus on one improvement per refactoring session
- **Readability**: Code should be easier to understand after refactoring

### When to Refactor
- Before adding new features (clean the area first)
- During code review (boy scout rule: leave code better than you found it)
- When fixing bugs (improve code quality while fixing)
- When code smells are detected
- During tech debt sprints

### When NOT to Refactor
- System is completely broken - fix first
- Deadline is extremely tight - note tech debt for later
- Code will be replaced soon anyway
- You don't understand the code well enough

## Code Smells

### 1. Long Method/Function
**Smell**: Method is too long (>20-30 lines)

**Before**:
```javascript
function processOrder(order) {
  // Validate
  if (!order.items || order.items.length === 0) {
    throw new Error('Order has no items');
  }
  if (!order.customer) {
    throw new Error('Order has no customer');
  }

  // Calculate totals
  let subtotal = 0;
  for (const item of order.items) {
    subtotal += item.price * item.quantity;
  }
  const tax = subtotal * 0.1;
  const total = subtotal + tax;

  // Apply discount
  let discount = 0;
  if (order.customer.isPremium) {
    discount = total * 0.2;
  } else if (order.customer.orders > 10) {
    discount = total * 0.1;
  }

  // Create invoice
  const invoice = {
    orderId: order.id,
    customer: order.customer.name,
    subtotal,
    tax,
    discount,
    total: total - discount
  };

  return invoice;
}
```

**After (Extract Method)**:
```javascript
function processOrder(order) {
  validateOrder(order);
  const subtotal = calculateSubtotal(order.items);
  const tax = calculateTax(subtotal);
  const discount = calculateDiscount(order.customer, subtotal + tax);

  return createInvoice(order, subtotal, tax, discount);
}

function validateOrder(order) {
  if (!order.items?.length) throw new Error('Order has no items');
  if (!order.customer) throw new Error('Order has no customer');
}

function calculateSubtotal(items) {
  return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}

function calculateTax(subtotal) {
  return subtotal * 0.1;
}

function calculateDiscount(customer, total) {
  if (customer.isPremium) return total * 0.2;
  if (customer.orders > 10) return total * 0.1;
  return 0;
}

function createInvoice(order, subtotal, tax, discount) {
  return {
    orderId: order.id,
    customer: order.customer.name,
    subtotal,
    tax,
    discount,
    total: subtotal + tax - discount
  };
}
```

### 2. Duplicate Code
**Smell**: Same code appears in multiple places

**Before**:
```javascript
function getUserProfile(userId) {
  const response = await fetch(`/api/users/${userId}`);
  if (!response.ok) {
    throw new Error(`HTTP error ${response.status}`);
  }
  return await response.json();
}

function getUserPosts(userId) {
  const response = await fetch(`/api/users/${userId}/posts`);
  if (!response.ok) {
    throw new Error(`HTTP error ${response.status}`);
  }
  return await response.json();
}
```

**After (Extract Common Function)**:
```javascript
async function fetchJson(url) {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`HTTP error ${response.status}`);
  }
  return await response.json();
}

function getUserProfile(userId) {
  return fetchJson(`/api/users/${userId}`);
}

function getUserPosts(userId) {
  return fetchJson(`/api/users/${userId}/posts`);
}
```

### 3. Large Class/Module
**Smell**: Class has too many responsibilities

**Refactoring**: Split into multiple classes (Single Responsibility Principle)

```javascript
// Before: God class
class UserManager {
  createUser(data) { /* ... */ }
  updateUser(id, data) { /* ... */ }
  deleteUser(id) { /* ... */ }
  sendWelcomeEmail(user) { /* ... */ }
  sendPasswordReset(user) { /* ... */ }
  validateEmail(email) { /* ... */ }
  hashPassword(password) { /* ... */ }
  generateToken(user) { /* ... */ }
}

// After: Separate responsibilities
class UserRepository {
  create(data) { /* ... */ }
  update(id, data) { /* ... */ }
  delete(id) { /* ... */ }
}

class EmailService {
  sendWelcome(user) { /* ... */ }
  sendPasswordReset(user) { /* ... */ }
}

class UserValidator {
  validateEmail(email) { /* ... */ }
}

class AuthService {
  hashPassword(password) { /* ... */ }
  generateToken(user) { /* ... */ }
}
```

### 4. Long Parameter List
**Smell**: Function has too many parameters (>3-4)

**Before**:
```javascript
function createUser(name, email, password, age, country, city, zipCode) {
  // Implementation
}
```

**After (Introduce Parameter Object)**:
```javascript
function createUser(userData) {
  const { name, email, password, age, address } = userData;
  // Implementation
}

// Usage
createUser({
  name: 'John',
  email: 'john@example.com',
  password: 'secret',
  age: 30,
  address: { country: 'US', city: 'NYC', zipCode: '10001' }
});
```

### 5. Primitive Obsession
**Smell**: Using primitives instead of small objects

**Before**:
```javascript
function calculateDistance(lat1, lon1, lat2, lon2) {
  // Complex calculation
}

calculateDistance(40.7128, -74.0060, 51.5074, -0.1278);  // What do these numbers mean?
```

**After**:
```javascript
class Coordinate {
  constructor(latitude, longitude) {
    this.latitude = latitude;
    this.longitude = longitude;
  }

  distanceTo(other) {
    // Complex calculation using this.latitude, this.longitude, other.latitude, other.longitude
  }
}

const nyc = new Coordinate(40.7128, -74.0060);
const london = new Coordinate(51.5074, -0.1278);
const distance = nyc.distanceTo(london);  // Much clearer!
```

### 6. Switch/If-Else Chains
**Smell**: Long switch or if-else statements

**Before**:
```javascript
function calculateArea(shape) {
  if (shape.type === 'circle') {
    return Math.PI * shape.radius ** 2;
  } else if (shape.type === 'rectangle') {
    return shape.width * shape.height;
  } else if (shape.type === 'triangle') {
    return 0.5 * shape.base * shape.height;
  }
}
```

**After (Polymorphism)**:
```javascript
class Circle {
  constructor(radius) {
    this.radius = radius;
  }

  area() {
    return Math.PI * this.radius ** 2;
  }
}

class Rectangle {
  constructor(width, height) {
    this.width = width;
    this.height = height;
  }

  area() {
    return this.width * this.height;
  }
}

class Triangle {
  constructor(base, height) {
    this.base = base;
    this.height = height;
  }

  area() {
    return 0.5 * this.base * this.height;
  }
}

// Usage
const shape = new Circle(5);
const area = shape.area();
```

**Alternative (Strategy Pattern)**:
```javascript
const areaCalculators = {
  circle: (shape) => Math.PI * shape.radius ** 2,
  rectangle: (shape) => shape.width * shape.height,
  triangle: (shape) => 0.5 * shape.base * shape.height
};

function calculateArea(shape) {
  return areaCalculators[shape.type](shape);
}
```

### 7. Dead Code
**Smell**: Unused code, commented code

**Refactoring**: Delete it! Version control remembers it

```javascript
// Before
function processData(data) {
  // const oldWay = data.map(x => x * 2);  // Old implementation
  const result = data.map(x => x * 3);

  // function helperThatWasNeverCalled() {
  //   return 42;
  // }

  return result;
}

// After
function processData(data) {
  return data.map(x => x * 3);
}
```

### 8. Magic Numbers
**Smell**: Unexplained numeric literals

**Before**:
```javascript
function calculatePrice(quantity) {
  if (quantity > 100) {
    return quantity * 9.99 * 0.9;  // What are these numbers?
  }
  return quantity * 9.99;
}
```

**After**:
```javascript
const UNIT_PRICE = 9.99;
const BULK_DISCOUNT = 0.1;
const BULK_THRESHOLD = 100;

function calculatePrice(quantity) {
  const subtotal = quantity * UNIT_PRICE;

  if (quantity > BULK_THRESHOLD) {
    return subtotal * (1 - BULK_DISCOUNT);
  }

  return subtotal;
}
```

### 9. Poor Naming
**Smell**: Unclear variable/function names

**Before**:
```javascript
function calc(d) {
  const t = d * 0.1;
  const r = d + t;
  return r;
}
```

**After**:
```javascript
function calculateTotalWithTax(subtotal) {
  const TAX_RATE = 0.1;
  const tax = subtotal * TAX_RATE;
  const total = subtotal + tax;
  return total;
}
```

### 10. Deep Nesting
**Smell**: Too many nested blocks

**Before**:
```javascript
function processUser(user) {
  if (user) {
    if (user.isActive) {
      if (user.email) {
        if (validateEmail(user.email)) {
          sendEmail(user.email);
        }
      }
    }
  }
}
```

**After (Guard Clauses)**:
```javascript
function processUser(user) {
  if (!user) return;
  if (!user.isActive) return;
  if (!user.email) return;
  if (!validateEmail(user.email)) return;

  sendEmail(user.email);
}
```

## Refactoring Techniques

### 1. Extract Method/Function
Break long methods into smaller, focused functions.

### 2. Inline Method
Remove unnecessary indirection for simple one-line functions.

### 3. Extract Variable
Name complex expressions to improve clarity.

```javascript
// Before
if (platform.toUpperCase().indexOf('MAC') > -1 && browser.toUpperCase().indexOf('IE') > -1) {
  // ...
}

// After
const isMacOS = platform.toUpperCase().indexOf('MAC') > -1;
const isIE = browser.toUpperCase().indexOf('IE') > -1;
if (isMacOS && isIE) {
  // ...
}
```

### 4. Rename
Use clear, descriptive names.

### 5. Move Method/Field
Put methods and data where they logically belong.

### 6. Replace Conditional with Polymorphism
Use object-oriented design instead of switch statements.

### 7. Introduce Parameter Object
Group parameters that naturally belong together.

### 8. Replace Magic Number with Named Constant
Make the meaning of numbers explicit.

### 9. Encapsulate Field
Use getters/setters instead of public fields.

### 10. Replace Array with Object
Use objects when items have different meanings.

```javascript
// Before
const person = ['John', 'Doe', 30];  // What's the order?

// After
const person = { firstName: 'John', lastName: 'Doe', age: 30 };
```

## Refactoring Process

### Step 1: Ensure Tests Exist
```bash
# Run existing tests
npm test

# If no tests, write them first
# Create tests that verify current behavior
```

### Step 2: Make Small Changes
- Change one thing at a time
- Keep changes focused and atomic
- Don't mix refactoring with feature additions

### Step 3: Test After Each Change
```bash
# After every refactoring step
npm test
```

### Step 4: Commit Frequently
```bash
git add .
git commit -m "refactor: extract calculateTotal function"
```

### Step 5: Review and Iterate
- Does the code read better?
- Is it easier to understand?
- Are responsibilities clearer?
- Can you simplify further?

## SOLID Principles

### Single Responsibility Principle
A class should have one reason to change.

### Open/Closed Principle
Open for extension, closed for modification.

### Liskov Substitution Principle
Subtypes must be substitutable for their base types.

### Interface Segregation Principle
Many specific interfaces are better than one general interface.

### Dependency Inversion Principle
Depend on abstractions, not concretions.

## Refactoring Checklist

- [ ] Tests exist and pass before refactoring
- [ ] Changes are small and incremental
- [ ] Tests pass after each change
- [ ] Code is more readable after refactoring
- [ ] Responsibilities are clearer
- [ ] No behavior changes
- [ ] No new bugs introduced
- [ ] Performance not degraded
- [ ] Documentation updated if needed
- [ ] Commits are atomic and well-described

## Tools to Use

- **Read**: Examine code to refactor
- **Edit**: Make refactoring changes
- **Bash**: Run tests after each change
- **Grep**: Find similar patterns to refactor
- **Glob**: Find related files

## Red-Green-Refactor (TDD Cycle)

1. **Red**: Write a failing test
2. **Green**: Write minimal code to pass
3. **Refactor**: Improve code while keeping tests green

## Remember

- Refactoring is ongoing, not a one-time event
- Make small, safe changes
- Test constantly
- Preserve behavior
- Improve readability
- Remove duplication
- Simplify complexity
- Don't refactor and add features simultaneously

---

**Version**: 1.0
**Last Updated**: 2025-01-01