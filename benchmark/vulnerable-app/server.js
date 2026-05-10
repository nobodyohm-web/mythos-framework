const express = require('express');
const sqlite3 = require('better-sqlite3');
const session = require('express-session');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ========================================================================
// VULNERABILITY #1: Hardcoded secret + weak session config
// Severity: CRITICAL | Category: CWE-798 (Hardcoded Credentials)
// ========================================================================
const API_SECRET = "sk-prod-8f3k2j5h7g9d1s4a6p0w"; // Hardcoded API key
const JWT_SECRET = "supersecret123"; // Weak, hardcoded JWT secret

app.use(session({
  secret: 'keyboard cat',           // Weak session secret
  resave: true,
  saveUninitialized: true,
  cookie: { secure: false, httpOnly: false } // Missing secure + httpOnly
}));

// ========================================================================
// VULNERABILITY #2: SQL Injection
// Severity: CRITICAL | Category: CWE-89
// ========================================================================
const db = new sqlite3('users.db');
db.exec(`CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY,
  username TEXT,
  password TEXT,
  email TEXT,
  role TEXT DEFAULT 'user',
  api_key TEXT
)`);
db.exec(`INSERT OR IGNORE INTO users (id, username, password, email, role, api_key)
  VALUES (1, 'admin', 'admin123', 'admin@company.com', 'admin', '${API_SECRET}')`);

app.post('/api/login', (req, res) => {
  const { username, password } = req.body;
  // VULN: Direct string interpolation in SQL query
  const query = `SELECT * FROM users WHERE username = '${username}' AND password = '${password}'`;
  try {
    const user = db.prepare(query).get();
    if (user) {
      req.session.user = user;
      req.session.isAdmin = user.role === 'admin';
      res.json({ success: true, user: { id: user.id, username: user.username, role: user.role, api_key: user.api_key } });
    } else {
      res.status(401).json({ error: 'Invalid credentials' });
    }
  } catch (e) {
    // VULN #3: Verbose error messages expose internals
    res.status(500).json({ error: e.message, stack: e.stack, query: query });
  }
});

// ========================================================================
// VULNERABILITY #4: Broken Access Control (IDOR)
// Severity: HIGH | Category: CWE-639
// ========================================================================
app.get('/api/users/:id', (req, res) => {
  // VULN: No authorization check — any user can access any profile
  const user = db.prepare('SELECT * FROM users WHERE id = ?').get(req.params.id);
  if (user) {
    // VULN #5: Leaks sensitive data (password, api_key in response)
    res.json(user);
  } else {
    res.status(404).json({ error: 'User not found' });
  }
});

// ========================================================================
// VULNERABILITY #6: Cross-Site Scripting (XSS) — Reflected
// Severity: HIGH | Category: CWE-79
// ========================================================================
app.get('/search', (req, res) => {
  const query = req.query.q;
  // VULN: User input directly injected into HTML response without sanitization
  res.send(`
    <html>
      <head><title>Search Results</title></head>
      <body>
        <h1>Search Results for: ${query}</h1>
        <p>No results found for "${query}".</p>
        <form action="/search">
          <input name="q" value="${query}" />
          <button type="submit">Search</button>
        </form>
      </body>
    </html>
  `);
});

// ========================================================================
// VULNERABILITY #7: Command Injection (RCE)
// Severity: CRITICAL | Category: CWE-78
// ========================================================================
app.post('/api/tools/ping', (req, res) => {
  const { host } = req.body;
  // VULN: Direct user input in shell command without sanitization
  exec(`ping -c 4 ${host}`, (error, stdout, stderr) => {
    res.json({ output: stdout || stderr, error: error?.message });
  });
});

// ========================================================================
// VULNERABILITY #8: Path Traversal
// Severity: HIGH | Category: CWE-22
// ========================================================================
app.get('/api/files/:filename', (req, res) => {
  const filename = req.params.filename;
  // VULN: No path validation — allows ../../etc/passwd
  const filepath = path.join(__dirname, 'uploads', filename);
  try {
    const content = fs.readFileSync(filepath, 'utf-8');
    res.json({ filename, content });
  } catch (e) {
    res.status(404).json({ error: `File not found: ${filepath}` }); // VULN: leaks server path
  }
});

// ========================================================================
// VULNERABILITY #9: Insecure Cryptography
// Severity: MEDIUM | Category: CWE-327, CWE-328
// ========================================================================
app.post('/api/users/register', (req, res) => {
  const { username, password, email } = req.body;
  // VULN: MD5 is cryptographically broken for password hashing
  const hashedPassword = crypto.createHash('md5').update(password).digest('hex');
  // VULN: No salt used
  try {
    const apiKey = crypto.randomBytes(4).toString('hex'); // VULN: Too short for API key (8 chars)
    db.prepare('INSERT INTO users (username, password, email, api_key) VALUES (?, ?, ?, ?)').run(
      username, hashedPassword, email, apiKey
    );
    res.json({ success: true, apiKey }); // VULN: Returns API key in response
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ========================================================================
// VULNERABILITY #10: Mass Assignment
// Severity: HIGH | Category: CWE-915
// ========================================================================
app.put('/api/users/:id', (req, res) => {
  // VULN: Accepts ANY field from user input including 'role' and 'api_key'
  const updates = req.body;
  const fields = Object.keys(updates).map(k => `${k} = ?`).join(', ');
  const values = Object.values(updates);
  try {
    db.prepare(`UPDATE users SET ${fields} WHERE id = ?`).run(...values, req.params.id);
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ========================================================================
// VULNERABILITY #11: Server-Side Request Forgery (SSRF)
// Severity: HIGH | Category: CWE-918
// ========================================================================
app.post('/api/tools/fetch-url', async (req, res) => {
  const { url } = req.body;
  // VULN: Fetches any URL including internal services (http://169.254.169.254/latest/meta-data/)
  try {
    const response = await fetch(url);
    const body = await response.text();
    res.json({ status: response.status, body: body.substring(0, 5000) });
  } catch (e) {
    res.json({ error: e.message });
  }
});

// ========================================================================
// VULNERABILITY #12: Rate Limiting Absent
// Severity: MEDIUM | Category: CWE-307
// ========================================================================
// No rate limiting on login endpoint — brute force possible

// ========================================================================
// VULNERABILITY #13: Missing Security Headers
// Severity: MEDIUM | Category: CWE-693
// ========================================================================
// No helmet(), no CORS config, no CSP, no X-Frame-Options

// ========================================================================
// VULNERABILITY #14: Prototype Pollution via merge
// Severity: HIGH | Category: CWE-1321
// ========================================================================
function deepMerge(target, source) {
  for (const key in source) {
    // VULN: No __proto__ / constructor check
    if (typeof source[key] === 'object' && source[key] !== null) {
      if (!target[key]) target[key] = {};
      deepMerge(target[key], source[key]);
    } else {
      target[key] = source[key];
    }
  }
  return target;
}

app.post('/api/settings', (req, res) => {
  const defaultSettings = { theme: 'dark', language: 'en', notifications: true };
  // VULN: User input merged without prototype pollution guard
  const settings = deepMerge(defaultSettings, req.body);
  res.json(settings);
});

// ========================================================================
// VULNERABILITY #15: Timing Attack on API key comparison
// Severity: MEDIUM | Category: CWE-208
// ========================================================================
app.get('/api/admin/data', (req, res) => {
  const providedKey = req.headers['x-api-key'];
  // VULN: Non-constant-time string comparison — vulnerable to timing attack
  if (providedKey === API_SECRET) {
    res.json({ users: db.prepare('SELECT * FROM users').all(), secret: 'internal-data' });
  } else {
    res.status(403).json({ error: 'Forbidden' });
  }
});

// ========================================================================
// Start server
// ========================================================================
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => { // VULN #16: Binds to all interfaces
  console.log(`Server running on port ${PORT}`);
});

module.exports = app;
