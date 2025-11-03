---
name: security-audit
description: Analyze code for security vulnerabilities including SQL injection, XSS, CSRF, authentication issues, and other OWASP Top 10 risks. Use when asked to audit security, find vulnerabilities, check for security issues, or perform security analysis.
---

# Security Audit Expert

You are performing a comprehensive security audit. Follow these guidelines to identify and remediate security vulnerabilities.

## Security Philosophy

### Core Principles
- **Security by Default**: Secure unless explicitly configured otherwise
- **Defense in Depth**: Multiple layers of security
- **Least Privilege**: Minimal necessary permissions
- **Fail Securely**: Errors should not expose sensitive information
- **Never Trust Input**: Validate and sanitize all inputs
- **Principle of Least Astonishment**: Security behavior should be predictable

## OWASP Top 10 Vulnerabilities

### 1. Injection (SQL, NoSQL, Command, LDAP)

**Vulnerable Code**:
```javascript
// SQL Injection
const query = `SELECT * FROM users WHERE username = '${username}' AND password = '${password}'`;
db.query(query);  // Attacker can use: username = "admin' OR '1'='1"

// NoSQL Injection
db.users.find({ username: req.body.username });  // Attacker can send: {$ne: null}

// Command Injection
exec(`ping ${req.query.host}`);  // Attacker can send: "google.com && rm -rf /"
```

**Secure Code**:
```javascript
// SQL - Use parameterized queries
const query = 'SELECT * FROM users WHERE username = ? AND password = ?';
db.query(query, [username, password]);

// NoSQL - Validate input types
if (typeof req.body.username !== 'string') {
  return res.status(400).json({ error: 'Invalid input' });
}
db.users.find({ username: req.body.username });

// Command - Avoid shell execution, use libraries
const { promisify } = require('util');
const ping = promisify(require('net-ping').createSession().ping);
await ping(validatedHost);
```

### 2. Broken Authentication

**Vulnerable Code**:
```javascript
// Weak password requirements
if (password.length >= 6) {  // Too short!
  createUser(username, password);
}

// Session fixation
app.post('/login', (req, res) => {
  if (authenticate(req.body)) {
    req.session.user = req.body.username;  // Session not regenerated
  }
});

// Missing rate limiting
app.post('/login', authenticate);  // Can be brute-forced
```

**Secure Code**:
```javascript
// Strong password requirements
const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{12,}$/;
if (!passwordRegex.test(password)) {
  return res.status(400).json({
    error: 'Password must be 12+ chars with uppercase, lowercase, number, and special char'
  });
}

// Regenerate session on login
app.post('/login', (req, res) => {
  if (authenticate(req.body)) {
    req.session.regenerate((err) => {
      req.session.user = req.body.username;
      res.json({ success: true });
    });
  }
});

// Rate limiting
const rateLimit = require('express-rate-limit');
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: 'Too many login attempts'
});
app.post('/login', loginLimiter, authenticate);
```

### 3. Sensitive Data Exposure

**Vulnerable Code**:
```javascript
// Exposing sensitive data
app.get('/api/users/:id', (req, res) => {
  const user = await User.findById(req.params.id);
  res.json(user);  // Includes password hash, ssn, etc!
});

// Storing passwords in plaintext
db.users.insert({ username, password });  // NEVER!

// Logging sensitive data
console.log('User login:', { email, password });  // Logs password!
```

**Secure Code**:
```javascript
// Filter sensitive fields
app.get('/api/users/:id', async (req, res) => {
  const user = await User.findById(req.params.id);
  const { password, ssn, ...publicData } = user.toObject();
  res.json(publicData);
});

// Hash passwords
const bcrypt = require('bcrypt');
const hashedPassword = await bcrypt.hash(password, 12);  // Salt rounds: 12
db.users.insert({ username, password: hashedPassword });

// Never log sensitive data
console.log('User login attempt:', { email });  // Only log email
```

### 4. XML External Entities (XXE)

**Vulnerable Code**:
```javascript
const libxmljs = require('libxmljs');
const xml = libxmljs.parseXml(req.body.xml);  // Can load external entities
```

**Secure Code**:
```javascript
const libxmljs = require('libxmljs');
const xml = libxmljs.parseXml(req.body.xml, {
  noent: false,  // Disable entity expansion
  nonet: true    // Disable network access
});
```

### 5. Broken Access Control

**Vulnerable Code**:
```javascript
// Insecure direct object reference
app.get('/api/orders/:id', (req, res) => {
  const order = await Order.findById(req.params.id);
  res.json(order);  // Any user can see any order!
});

// Missing authorization check
app.delete('/api/users/:id', (req, res) => {
  await User.deleteOne({ _id: req.params.id });  // Anyone can delete anyone!
});
```

**Secure Code**:
```javascript
// Check ownership
app.get('/api/orders/:id', authenticate, async (req, res) => {
  const order = await Order.findOne({
    _id: req.params.id,
    userId: req.user.id  // Only return user's own orders
  });

  if (!order) {
    return res.status(404).json({ error: 'Order not found' });
  }

  res.json(order);
});

// Check authorization
app.delete('/api/users/:id', authenticate, authorize('admin'), async (req, res) => {
  // Only admins can delete
  await User.deleteOne({ _id: req.params.id });
  res.status(204).send();
});
```

### 6. Security Misconfiguration

**Vulnerable Code**:
```javascript
// Exposing stack traces
app.use((err, req, res, next) => {
  res.status(500).json({ error: err.stack });  // Leaks internal info!
});

// Default credentials
const dbPassword = 'admin123';  // Default password!

// Missing security headers
// No headers configured
```

**Secure Code**:
```javascript
// Generic error messages in production
app.use((err, req, res, next) => {
  console.error(err);  // Log for debugging

  res.status(500).json({
    error: process.env.NODE_ENV === 'production'
      ? 'Internal server error'
      : err.message
  });
});

// Use environment variables
const dbPassword = process.env.DB_PASSWORD;
if (!dbPassword) {
  throw new Error('DB_PASSWORD not configured');
}

// Security headers
const helmet = require('helmet');
app.use(helmet());
```

### 7. Cross-Site Scripting (XSS)

**Vulnerable Code**:
```javascript
// Reflected XSS
app.get('/search', (req, res) => {
  res.send(`<h1>Results for: ${req.query.q}</h1>`);  // Script injection!
});

// Stored XSS
app.post('/comments', async (req, res) => {
  await Comment.create({ text: req.body.comment });  // Stored without sanitization
});

// DOM-based XSS (client-side)
document.getElementById('output').innerHTML = userInput;  // Script execution!
```

**Secure Code**:
```javascript
// Escape output
const escapeHtml = require('escape-html');
app.get('/search', (req, res) => {
  res.send(`<h1>Results for: ${escapeHtml(req.query.q)}</h1>`);
});

// Sanitize input
const sanitizeHtml = require('sanitize-html');
app.post('/comments', async (req, res) => {
  const cleanComment = sanitizeHtml(req.body.comment, {
    allowedTags: ['b', 'i', 'em', 'strong'],
    allowedAttributes: {}
  });
  await Comment.create({ text: cleanComment });
});

// Use textContent instead of innerHTML
document.getElementById('output').textContent = userInput;  // Safe!

// Or use a framework that auto-escapes (React, Vue)
<div>{userInput}</div>  // React automatically escapes
```

### 8. Insecure Deserialization

**Vulnerable Code**:
```javascript
// Deserializing untrusted data
const userData = JSON.parse(req.cookies.user);  // Can execute code in some languages
eval(req.body.code);  // NEVER use eval!
```

**Secure Code**:
```javascript
// Validate before deserializing
try {
  const userData = JSON.parse(req.cookies.user);
  if (!isValidUserObject(userData)) {
    throw new Error('Invalid user data');
  }
} catch (e) {
  // Handle error
}

// Never use eval - use safe alternatives
const safeEval = require('safe-eval');
const result = safeEval(req.body.expression, context);
```

### 9. Using Components with Known Vulnerabilities

**Check Dependencies**:
```bash
# Check for vulnerabilities
npm audit

# Fix vulnerabilities
npm audit fix

# View details
npm audit --json
```

**Secure Practices**:
```javascript
// Keep dependencies updated
// Use package-lock.json or yarn.lock
// Monitor security advisories
// Use tools like Snyk or Dependabot
```

### 10. Insufficient Logging & Monitoring

**Vulnerable Code**:
```javascript
// No logging
app.post('/login', authenticate);  // No audit trail

// Logging sensitive data
logger.info('Login:', { username, password });  // Logs password!
```

**Secure Code**:
```javascript
// Proper logging
const winston = require('winston');
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'security.log' })
  ]
});

app.post('/login', (req, res) => {
  const result = authenticate(req.body);

  logger.info('Login attempt', {
    username: req.body.username,
    success: result.success,
    ip: req.ip,
    userAgent: req.get('user-agent'),
    timestamp: new Date().toISOString()
  });

  if (!result.success) {
    // Track failed attempts for rate limiting
    trackFailedLogin(req.body.username, req.ip);
  }

  res.json(result);
});
```

## Additional Security Concerns

### Cross-Site Request Forgery (CSRF)

**Vulnerable Code**:
```javascript
app.post('/api/transfer', authenticate, (req, res) => {
  transferMoney(req.user, req.body.to, req.body.amount);  // No CSRF protection
});
```

**Secure Code**:
```javascript
const csrf = require('csurf');
const csrfProtection = csrf({ cookie: true });

app.post('/api/transfer', authenticate, csrfProtection, (req, res) => {
  transferMoney(req.user, req.body.to, req.body.amount);
});

// Send token to client
app.get('/form', csrfProtection, (req, res) => {
  res.render('form', { csrfToken: req.csrfToken() });
});
```

### Insecure Cryptography

**Vulnerable Code**:
```javascript
// Weak hashing
const crypto = require('crypto');
const hash = crypto.createHash('md5').update(password).digest('hex');  // MD5 is broken!

// Weak encryption
const encrypted = Buffer.from(data).toString('base64');  // Not encryption!
```

**Secure Code**:
```javascript
// Strong hashing with bcrypt
const bcrypt = require('bcrypt');
const hash = await bcrypt.hash(password, 12);

// Strong encryption
const crypto = require('crypto');
const algorithm = 'aes-256-gcm';
const key = crypto.randomBytes(32);
const iv = crypto.randomBytes(16);
const cipher = crypto.createCipheriv(algorithm, key, iv);

let encrypted = cipher.update(data, 'utf8', 'hex');
encrypted += cipher.final('hex');
const authTag = cipher.getAuthTag();
```

### Server-Side Request Forgery (SSRF)

**Vulnerable Code**:
```javascript
app.get('/fetch', async (req, res) => {
  const response = await fetch(req.query.url);  // Can access internal services!
  res.send(await response.text());
});
```

**Secure Code**:
```javascript
const { URL } = require('url');

app.get('/fetch', async (req, res) => {
  try {
    const url = new URL(req.query.url);

    // Whitelist allowed domains
    const allowedHosts = ['api.example.com', 'cdn.example.com'];
    if (!allowedHosts.includes(url.hostname)) {
      return res.status(400).json({ error: 'Invalid URL' });
    }

    // Prevent private IP access
    const ip = await dns.lookup(url.hostname);
    if (ip.address.startsWith('10.') || ip.address.startsWith('192.168.')) {
      return res.status(400).json({ error: 'Private IPs not allowed' });
    }

    const response = await fetch(url.href);
    res.send(await response.text());
  } catch (e) {
    res.status(400).json({ error: 'Invalid request' });
  }
});
```

### Path Traversal

**Vulnerable Code**:
```javascript
app.get('/files/:filename', (req, res) => {
  const filePath = `./uploads/${req.params.filename}`;
  res.sendFile(filePath);  // Can access ../../../etc/passwd
});
```

**Secure Code**:
```javascript
const path = require('path');

app.get('/files/:filename', (req, res) => {
  const filename = path.basename(req.params.filename);  // Remove path components
  const filePath = path.join(__dirname, 'uploads', filename);

  // Verify path is within uploads directory
  const uploadsDir = path.join(__dirname, 'uploads');
  if (!filePath.startsWith(uploadsDir)) {
    return res.status(400).json({ error: 'Invalid path' });
  }

  res.sendFile(filePath);
});
```

## Security Audit Checklist

### Input Validation
- [ ] All user inputs are validated
- [ ] Whitelist validation used where possible
- [ ] Type checking performed
- [ ] Length limits enforced
- [ ] Special characters handled properly

### Authentication & Authorization
- [ ] Strong password requirements enforced
- [ ] Passwords are hashed (bcrypt, argon2)
- [ ] Session management is secure
- [ ] MFA available for sensitive operations
- [ ] Authorization checks on all protected resources

### Data Protection
- [ ] Sensitive data encrypted at rest
- [ ] HTTPS enforced (TLS 1.2+)
- [ ] Sensitive fields filtered from responses
- [ ] Secrets stored in environment variables
- [ ] No sensitive data in logs

### API Security
- [ ] Rate limiting implemented
- [ ] CORS configured properly
- [ ] CSRF protection enabled
- [ ] Input validation on all endpoints
- [ ] Proper error handling

### Dependencies
- [ ] Dependencies are up to date
- [ ] No known vulnerabilities (npm audit)
- [ ] Using package-lock.json
- [ ] Regular security updates

### Logging & Monitoring
- [ ] Security events logged
- [ ] Failed login attempts tracked
- [ ] Unusual activity monitored
- [ ] Logs don't contain sensitive data
- [ ] Alerts configured for suspicious activity

### Configuration
- [ ] Debug mode disabled in production
- [ ] Error messages don't leak info
- [ ] Security headers configured (helmet)
- [ ] Default credentials changed
- [ ] Unnecessary features disabled

## Tools to Use

- **Read**: Examine code for vulnerabilities
- **Grep**: Search for dangerous patterns (eval, innerHTML, etc.)
- **Bash**: Run security scanners (npm audit, etc.)
- **Glob**: Find files with sensitive data

## Output Format

Security audit should include:

1. **Executive Summary**: High-level findings
2. **Critical Issues**: Must fix immediately
3. **High Priority**: Should fix soon
4. **Medium Priority**: Fix when possible
5. **Low Priority**: Nice to have
6. **Recommendations**: Specific remediation steps

## Remember

- Assume all input is malicious
- Never trust client-side validation alone
- Keep dependencies updated
- Use security headers
- Log security events
- Perform regular audits
- Follow principle of least privilege
- Encrypt sensitive data
- Implement defense in depth

---

**Version**: 1.0
**Last Updated**: 2025-01-01