---
name: performance-optimizer
description: Identify and resolve performance bottlenecks, optimize algorithms, improve database queries, and enhance application speed. Use when asked to optimize, improve performance, fix slow code, or enhance speed.
---

# Performance Optimizer Expert

You are optimizing application performance. Follow these guidelines to identify bottlenecks and implement effective optimizations.

## Performance Philosophy

### Core Principles
- **Measure First**: Always profile before optimizing
- **Focus on Impact**: Optimize the biggest bottlenecks first
- **Don't Guess**: Use data to guide decisions
- **Maintain Readability**: Don't sacrifice maintainability for minor gains
- **Test After**: Verify improvements and ensure correctness

### The Performance Optimization Process

1. **Measure** - Profile to find bottlenecks
2. **Analyze** - Understand why it's slow
3. **Optimize** - Make targeted improvements
4. **Verify** - Measure again to confirm improvement
5. **Iterate** - Repeat for next bottleneck

## Frontend Performance

### 1. JavaScript Optimization

**Avoid Unnecessary Computations**:

```javascript
// Slow - Recalculates on every render
function UserList({ users }) {
  return (
    <div>
      {users.filter(u => u.active).map(u => (
        <UserCard key={u.id} user={u} />
      ))}
    </div>
  );
}

// Fast - Memoize expensive computations
import { useMemo } from 'react';

function UserList({ users }) {
  const activeUsers = useMemo(
    () => users.filter(u => u.active),
    [users]
  );

  return (
    <div>
      {activeUsers.map(u => (
        <UserCard key={u.id} user={u} />
      ))}
    </div>
  );
}
```

**Debounce/Throttle Event Handlers**:

```javascript
// Slow - Fires on every keystroke
function SearchBox() {
  const handleSearch = (e) => {
    fetchResults(e.target.value);  // Too many API calls!
  };

  return <input onChange={handleSearch} />;
}

// Fast - Debounced search
import { debounce } from 'lodash';
import { useCallback } from 'react';

function SearchBox() {
  const handleSearch = useCallback(
    debounce((query) => {
      fetchResults(query);
    }, 300),
    []
  );

  return <input onChange={(e) => handleSearch(e.target.value)} />;
}
```

**Lazy Loading**:

```javascript
// Eager loading - Loads everything upfront
import HeavyComponent from './HeavyComponent';

// Lazy loading - Loads only when needed
const HeavyComponent = lazy(() => import('./HeavyComponent'));

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <HeavyComponent />
    </Suspense>
  );
}
```

### 2. Rendering Optimization

**Avoid Unnecessary Re-renders**:

```javascript
// Slow - Re-renders all items on any change
function List({ items }) {
  return items.map(item => <Item data={item} />);
}

// Fast - Memoized components
const Item = memo(({ data }) => {
  return <div>{data.name}</div>;
});

function List({ items }) {
  return items.map(item => <Item key={item.id} data={item} />);
}
```

**Virtualize Long Lists**:

```javascript
// Slow - Renders 10,000 items
function List({ items }) {
  return (
    <div>
      {items.map(item => <Item key={item.id} data={item} />)}
    </div>
  );
}

// Fast - Virtualizes list (renders only visible items)
import { FixedSizeList } from 'react-window';

function List({ items }) {
  return (
    <FixedSizeList
      height={600}
      itemCount={items.length}
      itemSize={50}
      width="100%"
    >
      {({ index, style }) => (
        <div style={style}>
          <Item data={items[index]} />
        </div>
      )}
    </FixedSizeList>
  );
}
```

### 3. Network Optimization

**Bundle Splitting**:

```javascript
// webpack.config.js
module.exports = {
  optimization: {
    splitChunks: {
      chunks: 'all',
      cacheGroups: {
        vendor: {
          test: /[\\/]node_modules[\\/]/,
          name: 'vendors',
          priority: 10
        }
      }
    }
  }
};
```

**Compression**:

```javascript
// Enable gzip compression
const compression = require('compression');
app.use(compression());
```

**Caching**:

```javascript
// Set cache headers
app.use(express.static('public', {
  maxAge: '1y',
  etag: true
}));

// API response caching
const cache = new Map();

app.get('/api/data', (req, res) => {
  const cacheKey = req.url;

  if (cache.has(cacheKey)) {
    return res.json(cache.get(cacheKey));
  }

  const data = expensiveOperation();
  cache.set(cacheKey, data);
  res.json(data);
});
```

### 4. Image Optimization

```javascript
// Use modern formats (WebP)
<picture>
  <source srcset="image.webp" type="image/webp" />
  <img src="image.jpg" alt="..." />
</picture>

// Lazy load images
<img src="image.jpg" loading="lazy" alt="..." />

// Responsive images
<img
  srcset="small.jpg 320w, medium.jpg 768w, large.jpg 1200w"
  sizes="(max-width: 320px) 280px, (max-width: 768px) 720px, 1200px"
  src="medium.jpg"
  alt="..."
/>
```

## Backend Performance

### 1. Algorithm Optimization

**Choose Efficient Algorithms**:

```javascript
// Slow - O(n²) - Quadratic time
function findDuplicates(arr) {
  const duplicates = [];
  for (let i = 0; i < arr.length; i++) {
    for (let j = i + 1; j < arr.length; j++) {
      if (arr[i] === arr[j] && !duplicates.includes(arr[i])) {
        duplicates.push(arr[i]);
      }
    }
  }
  return duplicates;
}

// Fast - O(n) - Linear time
function findDuplicates(arr) {
  const seen = new Set();
  const duplicates = new Set();

  for (const item of arr) {
    if (seen.has(item)) {
      duplicates.add(item);
    }
    seen.add(item);
  }

  return Array.from(duplicates);
}
```

**Use Appropriate Data Structures**:

```javascript
// Slow - Array lookup O(n)
const users = [{ id: 1, name: 'John' }, { id: 2, name: 'Jane' }];
const user = users.find(u => u.id === 1);

// Fast - Map lookup O(1)
const users = new Map([
  [1, { id: 1, name: 'John' }],
  [2, { id: 2, name: 'Jane' }]
]);
const user = users.get(1);
```

### 2. Database Optimization

**Add Indexes**:

```javascript
// Slow - Full table scan
db.users.find({ email: 'user@example.com' });

// Fast - Index scan
db.users.createIndex({ email: 1 });
db.users.find({ email: 'user@example.com' });  // Uses index
```

**Avoid N+1 Queries**:

```javascript
// Slow - N+1 queries (1 for posts + N for authors)
const posts = await Post.findAll();
for (const post of posts) {
  post.author = await User.findById(post.authorId);  // N queries!
}

// Fast - 2 queries with JOIN
const posts = await Post.findAll({
  include: [{ model: User, as: 'author' }]
});

// Or with eager loading
const posts = await Post.findAll();
const authorIds = [...new Set(posts.map(p => p.authorId))];
const authors = await User.findAll({ where: { id: authorIds } });
const authorMap = new Map(authors.map(a => [a.id, a]));
posts.forEach(p => p.author = authorMap.get(p.authorId));
```

**Optimize Queries**:

```javascript
// Slow - Fetches all columns
const users = await db.query('SELECT * FROM users WHERE active = true');

// Fast - Only select needed columns
const users = await db.query('SELECT id, name, email FROM users WHERE active = true');

// Slow - No limit
const posts = await Post.findAll();

// Fast - Pagination
const posts = await Post.findAll({
  limit: 20,
  offset: (page - 1) * 20
});
```

**Use Connection Pooling**:

```javascript
// Slow - New connection for each query
const client = new Client(config);
await client.connect();
const result = await client.query('SELECT * FROM users');
await client.end();

// Fast - Connection pool
const pool = new Pool(config);
const result = await pool.query('SELECT * FROM users');
// Connection automatically returned to pool
```

### 3. Caching Strategies

**In-Memory Caching**:

```javascript
const NodeCache = require('node-cache');
const cache = new NodeCache({ stdTTL: 600 });

async function getUser(id) {
  const cacheKey = `user:${id}`;

  // Check cache first
  const cached = cache.get(cacheKey);
  if (cached) return cached;

  // Fetch from database
  const user = await User.findById(id);

  // Store in cache
  cache.set(cacheKey, user);

  return user;
}
```

**Redis Caching**:

```javascript
const redis = require('redis');
const client = redis.createClient();

async function getData(key) {
  // Try cache first
  const cached = await client.get(key);
  if (cached) return JSON.parse(cached);

  // Compute/fetch data
  const data = await expensiveOperation();

  // Cache for 1 hour
  await client.setEx(key, 3600, JSON.stringify(data));

  return data;
}
```

**HTTP Caching**:

```javascript
app.get('/api/data', (req, res) => {
  // Cache for 5 minutes
  res.set('Cache-Control', 'public, max-age=300');

  // ETags for conditional requests
  const data = getData();
  const etag = generateETag(data);

  if (req.get('If-None-Match') === etag) {
    return res.status(304).end();
  }

  res.set('ETag', etag);
  res.json(data);
});
```

### 4. Async Processing

**Use Background Jobs**:

```javascript
// Slow - Synchronous email sending
app.post('/api/orders', async (req, res) => {
  const order = await createOrder(req.body);
  await sendConfirmationEmail(order);  // Blocks response!
  res.json(order);
});

// Fast - Background job
const queue = require('bull');
const emailQueue = new queue('email');

app.post('/api/orders', async (req, res) => {
  const order = await createOrder(req.body);

  // Queue email for background processing
  await emailQueue.add({ orderId: order.id });

  res.json(order);
});

// Worker process
emailQueue.process(async (job) => {
  const order = await Order.findById(job.data.orderId);
  await sendConfirmationEmail(order);
});
```

**Parallel Processing**:

```javascript
// Slow - Sequential
const user = await fetchUser(userId);
const posts = await fetchPosts(userId);
const comments = await fetchComments(userId);

// Fast - Parallel
const [user, posts, comments] = await Promise.all([
  fetchUser(userId),
  fetchPosts(userId),
  fetchComments(userId)
]);
```

### 5. Memory Optimization

**Avoid Memory Leaks**:

```javascript
// Memory leak - Event listener not removed
class Component {
  constructor() {
    window.addEventListener('resize', this.handleResize);
  }
}

// Fixed - Remove listener on cleanup
class Component {
  constructor() {
    this.handleResize = this.handleResize.bind(this);
    window.addEventListener('resize', this.handleResize);
  }

  destroy() {
    window.removeEventListener('resize', this.handleResize);
  }
}
```

**Stream Large Data**:

```javascript
// Slow - Loads entire file into memory
app.get('/download', (req, res) => {
  const data = fs.readFileSync('large-file.pdf');
  res.send(data);
});

// Fast - Streams file
app.get('/download', (req, res) => {
  const stream = fs.createReadStream('large-file.pdf');
  stream.pipe(res);
});
```

## Performance Profiling Tools

### Node.js Profiling

```bash
# CPU profiling
node --prof app.js
node --prof-process isolate-*.log

# Heap snapshot
node --inspect app.js
# Open chrome://inspect, take heap snapshot

# Clinic.js
npm install -g clinic
clinic doctor -- node app.js
```

### Browser Profiling

```javascript
// Performance API
const start = performance.now();
expensiveOperation();
const duration = performance.now() - start;
console.log(`Operation took ${duration}ms`);

// User Timing API
performance.mark('start-fetch');
await fetch('/api/data');
performance.mark('end-fetch');
performance.measure('fetch-duration', 'start-fetch', 'end-fetch');
```

### Database Profiling

```sql
-- PostgreSQL
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'user@example.com';

-- MongoDB
db.users.find({ email: 'user@example.com' }).explain('executionStats');

-- MySQL
EXPLAIN SELECT * FROM users WHERE email = 'user@example.com';
```

## Performance Metrics

### Core Web Vitals

- **LCP (Largest Contentful Paint)**: < 2.5s
- **FID (First Input Delay)**: < 100ms
- **CLS (Cumulative Layout Shift)**: < 0.1

### Backend Metrics

- **Response Time**: p95 < 200ms
- **Throughput**: Requests per second
- **Error Rate**: < 1%
- **CPU Usage**: < 70%
- **Memory Usage**: Stable, no leaks

## Performance Checklist

### Frontend
- [ ] Code splitting implemented
- [ ] Images optimized and lazy loaded
- [ ] Bundle size < 200KB (gzipped)
- [ ] Critical CSS inlined
- [ ] JavaScript deferred/async
- [ ] Fonts optimized (subset, preload)
- [ ] Service worker for caching
- [ ] CDN for static assets

### Backend
- [ ] Database queries optimized
- [ ] Indexes on frequently queried columns
- [ ] Connection pooling enabled
- [ ] Caching strategy implemented
- [ ] API responses compressed
- [ ] Background jobs for slow tasks
- [ ] Rate limiting to prevent abuse
- [ ] Load balancing configured

### Database
- [ ] Proper indexes created
- [ ] Query plans analyzed
- [ ] N+1 queries eliminated
- [ ] Pagination implemented
- [ ] Connection pooling enabled
- [ ] Query result caching
- [ ] Database statistics updated
- [ ] Slow query log monitored

## Tools to Use

- **Read**: Examine code for performance issues
- **Bash**: Run profiling tools, benchmarks
- **Edit**: Implement optimizations
- **Grep**: Find performance anti-patterns

## Remember

- Profile before optimizing
- Optimize the biggest bottleneck first
- Measure the impact of changes
- Don't sacrifice readability for micro-optimizations
- Use appropriate data structures and algorithms
- Cache intelligently
- Process work asynchronously when possible
- Monitor performance in production

---

**Version**: 1.0
**Last Updated**: 2025-01-01