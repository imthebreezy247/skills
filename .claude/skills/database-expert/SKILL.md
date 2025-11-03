---
name: database-expert
description: Design database schemas, write optimized queries, manage migrations, and work with SQL and NoSQL databases. Use when asked about databases, schemas, queries, migrations, or data modeling.
---

# Database Expert

You are working with databases. Follow these guidelines for effective database design, querying, and management.

## Database Design Philosophy

### Core Principles
- **Normalization**: Reduce redundancy (but denormalize when needed for performance)
- **Integrity**: Enforce data consistency with constraints
- **Performance**: Design for efficient querying
- **Scalability**: Plan for growth
- **Simplicity**: Keep schema understandable and maintainable

## Relational Database Design (SQL)

### 1. Schema Design

**Normalized Schema (E-commerce Example)**:

```sql
-- Users table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  stock_quantity INTEGER NOT NULL DEFAULT 0,
  category_id INTEGER REFERENCES categories(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categories table
CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  parent_id INTEGER REFERENCES categories(id)
);

-- Orders table
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  status VARCHAR(50) NOT NULL,
  total_amount DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Order items table (junction table)
CREATE TABLE order_items (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL,
  price DECIMAL(10, 2) NOT NULL,  -- Snapshot price at time of order
  CONSTRAINT unique_order_product UNIQUE(order_id, product_id)
);

-- Indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
```

### 2. Normalization Forms

**1NF (First Normal Form)**:
- Atomic values (no arrays or lists)
- Each column has unique name
- No repeating groups

**2NF (Second Normal Form)**:
- Must be in 1NF
- No partial dependencies (all non-key columns depend on entire primary key)

**3NF (Third Normal Form)**:
- Must be in 2NF
- No transitive dependencies (non-key columns don't depend on other non-key columns)

**Example - Denormalization for Performance**:

```sql
-- Normalized (requires JOIN to get order total)
SELECT o.id, SUM(oi.price * oi.quantity) as total
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
GROUP BY o.id;

-- Denormalized (total stored in orders table for fast access)
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  total_amount DECIMAL(10, 2) NOT NULL,  -- Denormalized
  item_count INTEGER NOT NULL,            -- Denormalized
  created_at TIMESTAMP
);

-- Update total with trigger
CREATE OR REPLACE FUNCTION update_order_total()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE orders
  SET total_amount = (
    SELECT SUM(price * quantity)
    FROM order_items
    WHERE order_id = NEW.order_id
  )
  WHERE id = NEW.order_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER order_items_total
AFTER INSERT OR UPDATE OR DELETE ON order_items
FOR EACH ROW
EXECUTE FUNCTION update_order_total();
```

### 3. Relationships

**One-to-Many**:
```sql
-- One user has many orders
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255)
);

CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id)
);
```

**Many-to-Many**:
```sql
-- Students can enroll in many courses, courses have many students
CREATE TABLE students (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255)
);

CREATE TABLE courses (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255)
);

-- Junction table
CREATE TABLE enrollments (
  student_id INTEGER REFERENCES students(id),
  course_id INTEGER REFERENCES courses(id),
  enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  grade VARCHAR(2),
  PRIMARY KEY (student_id, course_id)
);
```

**One-to-One**:
```sql
-- One user has one profile
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255)
);

CREATE TABLE user_profiles (
  user_id INTEGER PRIMARY KEY REFERENCES users(id),
  bio TEXT,
  avatar_url VARCHAR(255)
);
```

### 4. Constraints

```sql
CREATE TABLE products (
  id SERIAL PRIMARY KEY,

  -- NOT NULL constraint
  name VARCHAR(255) NOT NULL,

  -- UNIQUE constraint
  sku VARCHAR(50) UNIQUE NOT NULL,

  -- CHECK constraint
  price DECIMAL(10, 2) CHECK (price >= 0),
  stock_quantity INTEGER CHECK (stock_quantity >= 0),

  -- FOREIGN KEY constraint
  category_id INTEGER REFERENCES categories(id),

  -- DEFAULT constraint
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  -- Composite unique constraint
  CONSTRAINT unique_name_category UNIQUE(name, category_id)
);
```

### 5. Indexes

**Types of Indexes**:

```sql
-- B-tree index (default, good for equality and range queries)
CREATE INDEX idx_users_email ON users(email);

-- Composite index
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- Unique index
CREATE UNIQUE INDEX idx_users_username ON users(username);

-- Partial index (index only subset of rows)
CREATE INDEX idx_active_users ON users(email) WHERE active = true;

-- Full-text search index (PostgreSQL)
CREATE INDEX idx_products_search ON products USING GIN(to_tsvector('english', name || ' ' || description));
```

**When to Use Indexes**:
- Columns frequently used in WHERE clauses
- Columns used in JOIN conditions
- Columns used in ORDER BY
- Foreign key columns

**When NOT to Use Indexes**:
- Small tables (full scan is faster)
- Columns with low cardinality (few distinct values)
- Columns frequently updated (indexes slow down writes)

### 6. Query Optimization

**Inefficient Query**:
```sql
-- N+1 problem
SELECT * FROM orders WHERE user_id = 1;
-- Then for each order:
SELECT * FROM order_items WHERE order_id = ?;
```

**Optimized Query**:
```sql
-- Single query with JOIN
SELECT
  o.id as order_id,
  o.total_amount,
  oi.product_id,
  oi.quantity,
  oi.price
FROM orders o
LEFT JOIN order_items oi ON oi.order_id = o.id
WHERE o.user_id = 1;
```

**Use EXPLAIN to Analyze**:
```sql
EXPLAIN ANALYZE
SELECT * FROM orders
WHERE user_id = 123
ORDER BY created_at DESC
LIMIT 10;
```

**Common Optimizations**:

```sql
-- Select only needed columns
SELECT id, name, email FROM users;  -- Not SELECT *

-- Use LIMIT for pagination
SELECT * FROM products
ORDER BY created_at DESC
LIMIT 20 OFFSET 40;

-- Use WHERE before JOIN when possible
SELECT o.*, u.name
FROM orders o
JOIN users u ON u.id = o.user_id
WHERE o.created_at > '2025-01-01';  -- Filter before join

-- Use subqueries wisely
SELECT *
FROM products
WHERE category_id IN (
  SELECT id FROM categories WHERE parent_id = 1
);

-- Better with JOIN
SELECT p.*
FROM products p
JOIN categories c ON c.id = p.category_id
WHERE c.parent_id = 1;
```

### 7. Transactions

```sql
-- Basic transaction
BEGIN;

UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;

COMMIT;  -- or ROLLBACK if error
```

**Isolation Levels**:
```sql
-- Read uncommitted (lowest isolation)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Read committed (default in PostgreSQL)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Repeatable read
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Serializable (highest isolation)
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

### 8. Migrations

**Creating Migrations**:

```sql
-- Migration: 001_create_users_table.sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Migration: 002_add_users_status.sql
ALTER TABLE users
ADD COLUMN status VARCHAR(50) DEFAULT 'active';

CREATE INDEX idx_users_status ON users(status);

-- Migration: 003_create_orders_table.sql
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  total_amount DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Using Migration Tools**:

```javascript
// Knex.js migration
exports.up = function(knex) {
  return knex.schema.createTable('users', (table) => {
    table.increments('id').primary();
    table.string('email').unique().notNullable();
    table.string('name').notNullable();
    table.timestamps(true, true);
  });
};

exports.down = function(knex) {
  return knex.schema.dropTable('users');
};
```

```python
# Django migration
from django.db import migrations, models

class Migration(migrations.Migration):
    dependencies = []

    operations = [
        migrations.CreateModel(
            name='User',
            fields=[
                ('id', models.AutoField(primary_key=True)),
                ('email', models.EmailField(unique=True)),
                ('name', models.CharField(max_length=255)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
            ],
        ),
    ]
```

## NoSQL Database Design

### MongoDB Schema Design

```javascript
// User document
{
  _id: ObjectId("..."),
  email: "user@example.com",
  name: "John Doe",
  profile: {
    bio: "Software developer",
    avatar: "https://...",
    preferences: {
      newsletter: true,
      theme: "dark"
    }
  },
  createdAt: ISODate("2025-01-01T00:00:00Z")
}

// Order document (embedded items)
{
  _id: ObjectId("..."),
  userId: ObjectId("..."),
  status: "completed",
  items: [
    {
      productId: ObjectId("..."),
      name: "Product Name",  // Denormalized for performance
      quantity: 2,
      price: 29.99
    }
  ],
  totalAmount: 59.98,
  createdAt: ISODate("2025-01-01T00:00:00Z")
}
```

**Embedding vs Referencing**:

```javascript
// Embed when:
// - Data is always accessed together
// - Data doesn't change often
// - Embedded data size is bounded

// One-to-Few (embed)
{
  _id: ObjectId("..."),
  name: "John Doe",
  addresses: [
    { street: "123 Main St", city: "NYC" },
    { street: "456 Oak Ave", city: "LA" }
  ]
}

// Reference when:
// - Data is large
// - Data changes frequently
// - Data is accessed independently

// One-to-Many (reference)
{
  _id: ObjectId("user1"),
  name: "John Doe"
}

{
  _id: ObjectId("order1"),
  userId: ObjectId("user1"),
  totalAmount: 99.99
}
```

**Indexes in MongoDB**:

```javascript
// Single field index
db.users.createIndex({ email: 1 });

// Compound index
db.orders.createIndex({ userId: 1, status: 1 });

// Text index for search
db.products.createIndex({ name: "text", description: "text" });

// Unique index
db.users.createIndex({ email: 1 }, { unique: true });

// TTL index (auto-delete old documents)
db.sessions.createIndex({ createdAt: 1 }, { expireAfterSeconds: 3600 });
```

**Aggregation Pipeline**:

```javascript
db.orders.aggregate([
  // Stage 1: Filter
  { $match: { status: "completed" } },

  // Stage 2: Group and sum
  {
    $group: {
      _id: "$userId",
      totalSpent: { $sum: "$totalAmount" },
      orderCount: { $sum: 1 }
    }
  },

  // Stage 3: Sort
  { $sort: { totalSpent: -1 } },

  // Stage 4: Limit
  { $limit: 10 },

  // Stage 5: Lookup (join)
  {
    $lookup: {
      from: "users",
      localField: "_id",
      foreignField: "_id",
      as: "user"
    }
  }
]);
```

## Database Best Practices

### 1. Security

```sql
-- Create user with limited permissions
CREATE USER app_user WITH PASSWORD 'secure_password';

-- Grant only necessary permissions
GRANT SELECT, INSERT, UPDATE ON orders TO app_user;
GRANT SELECT ON products TO app_user;

-- Never store passwords in plaintext
-- Use application-level hashing (bcrypt, argon2)

-- Use parameterized queries to prevent SQL injection
-- Bad: `SELECT * FROM users WHERE id = ${userId}`
-- Good: Use prepared statements with parameters
```

### 2. Backup and Recovery

```bash
# PostgreSQL backup
pg_dump -U postgres -d mydb > backup.sql

# PostgreSQL restore
psql -U postgres -d mydb < backup.sql

# MongoDB backup
mongodump --db mydb --out /backup/

# MongoDB restore
mongorestore --db mydb /backup/mydb/
```

### 3. Connection Pooling

```javascript
// PostgreSQL with pg-pool
const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  database: 'mydb',
  max: 20,  // Max connections in pool
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Use pool for queries
const result = await pool.query('SELECT * FROM users WHERE id = $1', [userId]);
```

### 4. Monitoring

```sql
-- PostgreSQL: Check slow queries
SELECT
  query,
  calls,
  total_time,
  mean_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;

-- Check table sizes
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Check index usage
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan,
  idx_tup_read
FROM pg_stat_user_indexes
WHERE idx_scan = 0;  -- Unused indexes
```

## Common Query Patterns

### Pagination

```sql
-- Offset-based (simple but slow for large offsets)
SELECT * FROM products
ORDER BY id
LIMIT 20 OFFSET 40;

-- Cursor-based (faster, better for infinite scroll)
SELECT * FROM products
WHERE id > 1000
ORDER BY id
LIMIT 20;
```

### Search

```sql
-- Full-text search (PostgreSQL)
SELECT * FROM products
WHERE to_tsvector('english', name || ' ' || description)
  @@ to_tsquery('english', 'laptop & gaming');

-- LIKE search (slower)
SELECT * FROM products
WHERE name ILIKE '%laptop%';
```

### Aggregation

```sql
-- Count, sum, average
SELECT
  category_id,
  COUNT(*) as product_count,
  AVG(price) as avg_price,
  SUM(stock_quantity) as total_stock
FROM products
GROUP BY category_id
HAVING COUNT(*) > 10;
```

### Window Functions

```sql
-- Row number within partition
SELECT
  name,
  category_id,
  price,
  ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank
FROM products;

-- Running total
SELECT
  date,
  amount,
  SUM(amount) OVER (ORDER BY date) as running_total
FROM sales;
```

## Tools to Use

- **Write**: Create migration files, schema files
- **Read**: Examine existing schemas
- **Bash**: Run database commands, migrations
- **Edit**: Modify existing schemas

## Database Checklist

- [ ] Schema is normalized appropriately
- [ ] Foreign key constraints defined
- [ ] Indexes on frequently queried columns
- [ ] Proper data types chosen
- [ ] Constraints enforce data integrity
- [ ] Migrations version controlled
- [ ] Backup strategy in place
- [ ] Connection pooling configured
- [ ] Query performance monitored
- [ ] Security permissions set correctly

## Remember

- Design schema for your access patterns
- Index strategically (helps reads, slows writes)
- Use transactions for data integrity
- Monitor query performance
- Backup regularly
- Version control migrations
- Use connection pooling
- Secure your database properly
- Plan for scalability from the start

---

**Version**: 1.0
**Last Updated**: 2025-01-01