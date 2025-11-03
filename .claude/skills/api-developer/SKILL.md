---
name: api-developer
description: Design and implement RESTful APIs, GraphQL APIs, and web services following best practices. Use when asked to create APIs, endpoints, web services, or backend services.
---

# API Developer Expert

You are designing and implementing robust, well-structured APIs. Follow these guidelines to create production-ready API services.

## API Design Philosophy

### Core Principles
- **Consistency**: Use consistent patterns across all endpoints
- **Clarity**: Endpoint purposes should be obvious
- **Versioning**: Plan for API evolution
- **Documentation**: Document all endpoints thoroughly
- **Security**: Secure by default
- **Performance**: Optimize for common use cases

## RESTful API Design

### 1. Resource Naming

**URL Structure**:
```
/{version}/{resource}/{identifier}/{sub-resource}

Examples:
GET    /api/v1/users              # List users
GET    /api/v1/users/123          # Get specific user
GET    /api/v1/users/123/orders   # Get user's orders
POST   /api/v1/users              # Create user
PUT    /api/v1/users/123          # Update user
DELETE /api/v1/users/123          # Delete user
```

**Naming Conventions**:
- Use **nouns**, not verbs: `/users` not `/getUsers`
- Use **plural** for collections: `/users` not `/user`
- Use **lowercase**: `/users` not `/Users`
- Use **hyphens** for multi-word: `/order-items` not `/orderItems`
- Keep URLs **shallow**: Max 2-3 levels deep

### 2. HTTP Methods

**GET** - Retrieve resources (idempotent, safe)
```javascript
// GET /api/v1/users
app.get('/api/v1/users', async (req, res) => {
  const { page = 1, limit = 20, sort = 'createdAt' } = req.query;

  const users = await User.find()
    .sort(sort)
    .limit(limit)
    .skip((page - 1) * limit);

  const total = await User.countDocuments();

  res.json({
    data: users,
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total,
      pages: Math.ceil(total / limit)
    }
  });
});
```

**POST** - Create resources
```javascript
// POST /api/v1/users
app.post('/api/v1/users', async (req, res) => {
  try {
    const { email, name, password } = req.body;

    // Validation
    if (!email || !name || !password) {
      return res.status(400).json({
        error: 'Validation failed',
        details: 'Email, name, and password are required'
      });
    }

    // Check if exists
    const existing = await User.findOne({ email });
    if (existing) {
      return res.status(409).json({
        error: 'User already exists'
      });
    }

    // Create user
    const user = await User.create({
      email,
      name,
      password: await hashPassword(password)
    });

    res.status(201).json({
      data: user,
      message: 'User created successfully'
    });
  } catch (error) {
    res.status(500).json({
      error: 'Internal server error',
      message: error.message
    });
  }
});
```

**PUT** - Replace entire resource
```javascript
// PUT /api/v1/users/:id
app.put('/api/v1/users/:id', async (req, res) => {
  const user = await User.findByIdAndUpdate(
    req.params.id,
    req.body,
    { new: true, overwrite: true }
  );

  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }

  res.json({ data: user });
});
```

**PATCH** - Partial update
```javascript
// PATCH /api/v1/users/:id
app.patch('/api/v1/users/:id', async (req, res) => {
  const user = await User.findByIdAndUpdate(
    req.params.id,
    { $set: req.body },
    { new: true }
  );

  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }

  res.json({ data: user });
});
```

**DELETE** - Remove resource
```javascript
// DELETE /api/v1/users/:id
app.delete('/api/v1/users/:id', async (req, res) => {
  const user = await User.findByIdAndDelete(req.params.id);

  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }

  res.status(204).send();  // No content
});
```

### 3. HTTP Status Codes

**Success Codes**:
- `200 OK` - Request succeeded (GET, PUT, PATCH)
- `201 Created` - Resource created (POST)
- `204 No Content` - Success with no response body (DELETE)

**Client Error Codes**:
- `400 Bad Request` - Invalid request data
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Authenticated but not authorized
- `404 Not Found` - Resource doesn't exist
- `409 Conflict` - Resource conflict (duplicate)
- `422 Unprocessable Entity` - Validation failed
- `429 Too Many Requests` - Rate limit exceeded

**Server Error Codes**:
- `500 Internal Server Error` - Generic server error
- `502 Bad Gateway` - Upstream service error
- `503 Service Unavailable` - Service temporarily unavailable

### 4. Request/Response Format

**Request Body**:
```json
{
  "email": "user@example.com",
  "name": "John Doe",
  "preferences": {
    "newsletter": true,
    "notifications": false
  }
}
```

**Success Response**:
```json
{
  "data": {
    "id": "123",
    "email": "user@example.com",
    "name": "John Doe",
    "createdAt": "2025-01-01T00:00:00Z"
  },
  "message": "User created successfully"
}
```

**Error Response**:
```json
{
  "error": "Validation failed",
  "details": {
    "email": "Email is already in use",
    "password": "Password must be at least 8 characters"
  },
  "code": "VALIDATION_ERROR",
  "timestamp": "2025-01-01T00:00:00Z"
}
```

### 5. Filtering, Sorting, Pagination

**Query Parameters**:
```
GET /api/v1/users?page=2&limit=20&sort=-createdAt&filter[status]=active&search=john

Implementation:
```javascript
app.get('/api/v1/users', async (req, res) => {
  const {
    page = 1,
    limit = 20,
    sort = 'createdAt',
    search,
    filter = {}
  } = req.query;

  // Build query
  const query = {};

  // Search
  if (search) {
    query.$or = [
      { name: { $regex: search, $options: 'i' } },
      { email: { $regex: search, $options: 'i' } }
    ];
  }

  // Filters
  if (filter.status) {
    query.status = filter.status;
  }

  // Execute query
  const users = await User.find(query)
    .sort(sort)
    .limit(parseInt(limit))
    .skip((page - 1) * limit);

  const total = await User.countDocuments(query);

  res.json({
    data: users,
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total,
      pages: Math.ceil(total / limit),
      hasNext: page * limit < total,
      hasPrev: page > 1
    }
  });
});
```

### 6. Authentication & Authorization

**JWT Authentication**:
```javascript
const jwt = require('jsonwebtoken');

// Login endpoint
app.post('/api/v1/auth/login', async (req, res) => {
  const { email, password } = req.body;

  const user = await User.findOne({ email });
  if (!user || !(await user.comparePassword(password))) {
    return res.status(401).json({
      error: 'Invalid credentials'
    });
  }

  const token = jwt.sign(
    { userId: user.id, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: '24h' }
  );

  res.json({
    token,
    user: {
      id: user.id,
      email: user.email,
      name: user.name
    }
  });
});

// Auth middleware
const authenticate = async (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Authentication required' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = await User.findById(decoded.userId);
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
};

// Protected route
app.get('/api/v1/profile', authenticate, (req, res) => {
  res.json({ data: req.user });
});
```

**Role-Based Access Control**:
```javascript
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }

    next();
  };
};

// Admin-only route
app.delete('/api/v1/users/:id',
  authenticate,
  authorize('admin'),
  async (req, res) => {
    // Delete user
  }
);
```

### 7. Validation

**Input Validation**:
```javascript
const { body, validationResult } = require('express-validator');

app.post('/api/v1/users',
  [
    body('email').isEmail().normalizeEmail(),
    body('password').isLength({ min: 8 }).matches(/\d/),
    body('name').trim().isLength({ min: 2, max: 100 })
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    // Create user
  }
);
```

**Custom Validation**:
```javascript
const validateUser = (req, res, next) => {
  const { email, password } = req.body;
  const errors = [];

  if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    errors.push({ field: 'email', message: 'Valid email required' });
  }

  if (!password || password.length < 8) {
    errors.push({ field: 'password', message: 'Password must be 8+ characters' });
  }

  if (errors.length > 0) {
    return res.status(422).json({ error: 'Validation failed', details: errors });
  }

  next();
};
```

### 8. Error Handling

**Global Error Handler**:
```javascript
// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);

  // Mongoose validation error
  if (err.name === 'ValidationError') {
    return res.status(422).json({
      error: 'Validation failed',
      details: Object.values(err.errors).map(e => ({
        field: e.path,
        message: e.message
      }))
    });
  }

  // JWT error
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({ error: 'Invalid token' });
  }

  // Default error
  res.status(err.status || 500).json({
    error: err.message || 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});
```

**Async Error Wrapper**:
```javascript
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

app.get('/api/v1/users', asyncHandler(async (req, res) => {
  const users = await User.find();
  res.json({ data: users });
}));
```

### 9. Rate Limiting

```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Max 100 requests per window
  message: 'Too many requests, please try again later',
  standardHeaders: true,
  legacyHeaders: false
});

app.use('/api/', limiter);

// Stricter limit for auth endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  skipSuccessfulRequests: true
});

app.use('/api/v1/auth/', authLimiter);
```

### 10. CORS

```javascript
const cors = require('cors');

app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  maxAge: 86400 // 24 hours
}));
```

## GraphQL API Design

**Schema Definition**:
```graphql
type User {
  id: ID!
  email: String!
  name: String!
  posts: [Post!]!
  createdAt: DateTime!
}

type Post {
  id: ID!
  title: String!
  content: String!
  author: User!
  published: Boolean!
}

type Query {
  user(id: ID!): User
  users(limit: Int, offset: Int): [User!]!
  post(id: ID!): Post
}

type Mutation {
  createUser(email: String!, name: String!, password: String!): User!
  updateUser(id: ID!, name: String): User
  deleteUser(id: ID!): Boolean!
}
```

**Resolvers**:
```javascript
const resolvers = {
  Query: {
    user: async (parent, { id }, context) => {
      return await User.findById(id);
    },
    users: async (parent, { limit = 10, offset = 0 }, context) => {
      return await User.find().limit(limit).skip(offset);
    }
  },
  Mutation: {
    createUser: async (parent, { email, name, password }, context) => {
      return await User.create({ email, name, password });
    }
  },
  User: {
    posts: async (user, args, context) => {
      return await Post.find({ authorId: user.id });
    }
  }
};
```

## API Documentation

**OpenAPI/Swagger**:
```javascript
/**
 * @swagger
 * /api/v1/users:
 *   get:
 *     summary: Get all users
 *     tags: [Users]
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *         description: Page number
 *     responses:
 *       200:
 *         description: List of users
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/User'
 */
```

## Best Practices

- **Versioning**: Include version in URL (`/api/v1/`)
- **HTTPS Only**: Enforce SSL in production
- **Input Validation**: Validate all inputs
- **Output Filtering**: Don't expose sensitive fields (passwords, tokens)
- **Caching**: Use ETags and cache headers
- **Compression**: Enable gzip compression
- **Logging**: Log all requests and errors
- **Monitoring**: Track API performance and errors
- **Testing**: Write integration tests for all endpoints

## Tools to Use

- **Write**: Create API files
- **Read**: Examine existing code
- **Bash**: Run the API server, test endpoints
- **Edit**: Modify existing API code

## Remember

- Security first: validate, sanitize, authenticate
- Be consistent in naming and structure
- Document everything
- Version your API from day one
- Handle errors gracefully
- Test thoroughly

---

**Version**: 1.0
**Last Updated**: 2025-01-01