# Insurance CRM Optimizer

Specialized skill for diagnosing, debugging, and optimizing insurance CRM systems, particularly those built with Next.js, Supabase, and integrating with HealthSherpa, Google Calendar, and communication platforms.

## When to Use This Skill

Use this skill when working with insurance CRM platforms that need:
- Database schema fixes and migrations
- Calendar integration debugging (Google Calendar, Calendly)
- Analytics and reporting troubleshooting
- Excel import functionality for daily submissions
- OAuth token refresh issues
- Supabase/database connectivity problems
- Performance optimization for large client databases

## Core Expertise

### 1. Insurance CRM Architecture
- **Stack**: Next.js 14+, Supabase, Clerk Auth, TypeScript
- **Key Features**: Client management, policy tracking, renewals, commissions, analytics
- **Integrations**: HealthSherpa, Google Calendar, Calendly, Twilio SMS, OpenAI
- **Data Models**: active_clients, policies, leads, tasks, communications, call_recordings

### 2. Common Issues & Fixes

#### Database Schema Problems
**Symptom**: Pages showing errors like "column does not exist" or "table does not exist"
**Cause**: SQL migration files exist but weren't executed in Supabase
**Fix**:
1. Locate migration SQL files in project root
2. Run in Supabase SQL Editor
3. Verify with `SELECT * FROM information_schema.columns WHERE table_name = 'table_name'`

**Common Missing Columns**:
- `active_clients.policy_expiry_date` - For renewals tracking
- `active_clients.renewal_status` - For renewal workflow
- `policies.clerk_user_id` - For user-scoped queries
- `call_recordings` table - For communication analytics

#### Calendar Integration Issues
**Symptom**: Calendar shows 500/503 errors, won't sync, or import fails
**Causes**:
1. Google OAuth token expired (`invalid_grant` error)
2. Calendar import intentionally disabled in code
3. Port mismatch between `.env.local` and dev server
4. Missing `google_calendar_token` in `agent_settings` table

**Fix**:
1. Check `.env.local` for correct `NEXT_PUBLIC_APP_URL` and port
2. Verify Google Cloud Console has matching redirect URI
3. Update Google OAuth credentials in agent_settings
4. Re-enable calendar import route if disabled

#### Analytics Showing Zero/Empty Data
**Symptom**: Reports show $0 revenue, 0 clients despite having data
**Causes**:
1. `policies` table missing `clerk_user_id` column
2. Queries filtering by wrong user field
3. Data in different table than code expects
4. RLS policies blocking access

**Fix**:
```sql
-- Add clerk_user_id to policies
ALTER TABLE policies ADD COLUMN IF NOT EXISTS clerk_user_id TEXT;

-- Populate from linked clients
UPDATE policies p
SET clerk_user_id = c.clerk_user_id
FROM active_clients c
WHERE p.client_id = c.id AND p.clerk_user_id IS NULL;

-- Create index
CREATE INDEX IF NOT EXISTS idx_policies_clerk_user_id ON policies(clerk_user_id);
```

### 3. Diagnostic Workflow

#### Step 1: Identify the Breaking Component
1. Check browser console (F12) for errors
2. Check Network tab for failed API calls (400/401/500/503)
3. Check server logs for backend errors
4. Note exact error messages and status codes

#### Step 2: Categorize the Issue
- **401/403**: Authentication or authorization (OAuth, Clerk, RLS)
- **404**: Missing endpoint or table
- **500**: Server error (check logs for details)
- **503**: Service intentionally disabled
- **Database errors**: Schema mismatch, missing columns/tables

#### Step 3: Locate Root Cause
- Search codebase for error-producing code
- Check if database schema matches code expectations
- Verify environment variables are correct
- Check for commented-out or disabled code
- Look for existing SQL migration files

#### Step 4: Implement Fix
- Database: Run SQL migrations
- OAuth: Update tokens and redirect URIs
- Code: Re-enable disabled features, fix misconfigurations
- Always verify fix with test queries/requests

### 4. HealthSherpa Integration

**Challenge**: No official API available
**Solution**: Excel import workflow

**Implementation**:
1. Daily Excel export from HealthSherpa portal
2. Upload via CRM import page
3. Parse with `xlsx`/`papaparse` libraries
4. Extract: client info, policies, applications, status
5. Store in `active_clients` and `policies` tables
6. Auto-create tasks for follow-ups

**Excel Import Best Practices**:
- Validate headers before processing
- Use fuzzy matching for client deduplication
- Auto-classify data (lead vs active client)
- Store raw data in JSONB column for reference
- Log all imports for audit trail

### 5. Performance Optimization

**For Large Client Databases (500+ clients)**:
1. Add database indexes on frequently queried columns:
   - `clerk_user_id` on all tables
   - `created_at` for date filtering
   - `status` for filtering active records
   - `policy_expiry_date` for renewals

2. Implement caching:
   - Use Redis or in-memory cache for dashboard queries
   - Cache client lists with 5-minute TTL
   - Invalidate cache on data updates

3. Optimize queries:
   - Use `.select()` to fetch only needed columns
   - Paginate large result sets
   - Use RPC functions for complex aggregations
   - Avoid N+1 queries with joins

### 6. Analytics & Reporting

**Key Metrics to Track**:
- Monthly Recurring Revenue (MRR)
- Active client count
- Policy count by carrier/type
- Conversion rates (lead → client)
- Renewal rates
- Average policy premium
- Client lifetime value

**Implementation**:
```typescript
// Example analytics query
const { data: metrics } = await supabase
  .from('policies')
  .select('premium, carrier, type, status')
  .eq('clerk_user_id', userId)
  .eq('status', 'Active');

const totalRevenue = metrics?.reduce((sum, p) => sum + (p.premium || 0), 0) || 0;
const carrierBreakdown = metrics?.reduce((acc, p) => {
  acc[p.carrier] = (acc[p.carrier] || 0) + 1;
  return acc;
}, {});
```

### 7. Common SQL Migrations

**Create Call Recordings Table**:
```sql
CREATE TABLE IF NOT EXISTS call_recordings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  clerk_user_id TEXT NOT NULL,
  phone_number TEXT NOT NULL,
  duration INTEGER DEFAULT 0,
  file_url TEXT NOT NULL,
  transcription TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_call_recordings_user_id ON call_recordings(clerk_user_id);
ALTER TABLE call_recordings ENABLE ROW LEVEL SECURITY;
```

**Add Renewal Tracking**:
```sql
ALTER TABLE active_clients
  ADD COLUMN IF NOT EXISTS renewal_status TEXT,
  ADD COLUMN IF NOT EXISTS policy_expiry_date DATE,
  ADD COLUMN IF NOT EXISTS last_contact_date TIMESTAMP WITH TIME ZONE;

CREATE INDEX idx_active_clients_policy_expiry ON active_clients(policy_expiry_date);
```

### 8. Environment Configuration Checklist

Verify these are set correctly:
- ✅ `NEXT_PUBLIC_SUPABASE_URL` - Matches Supabase project
- ✅ `NEXT_PUBLIC_SUPABASE_ANON_KEY` - Valid anon key
- ✅ `SUPABASE_SERVICE_ROLE_KEY` - For admin operations
- ✅ `CLERK_SECRET_KEY` - Valid Clerk key
- ✅ `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` - OAuth credentials
- ✅ `NEXT_PUBLIC_APP_URL` - Matches dev server port
- ✅ `GOOGLE_REDIRECT_URI` - Matches app URL + `/api/auth/google/callback`
- ✅ `OPENAI_API_KEY` - For AI features
- ✅ `TWILIO_*` - For SMS features

## Tools to Use

- **Read**: Examine code, configurations, SQL files
- **Grep**: Search for error strings, table names, API routes
- **Glob**: Find migration files, component files
- **Bash**: Run dev server, check processes, test database connections
- **Edit/Write**: Fix configuration, update code, create migration files

## Output Format

When diagnosing insurance CRM issues:

1. **Issue Summary**: What's broken and where
2. **Root Cause Analysis**: Why it's broken
3. **Immediate Fix**: Code or SQL changes needed
4. **Testing Steps**: How to verify the fix works
5. **Prevention**: How to avoid this issue in future

## Best Practices

1. **Always check Supabase first** - Most issues are database-related
2. **Verify RLS policies** - Ensure user can access their data
3. **Check browser console** - Front-end errors show there first
4. **Read server logs** - Back-end errors logged to console
5. **Test with real data** - Don't rely on mock data
6. **Document migrations** - Keep SQL files organized and versioned
7. **Use transactions** - For multi-step database updates
8. **Backup before migrations** - Always have rollback plan

## Version History

- **1.0** (2025-11-03): Initial release based on comprehensive CRM debugging session
  - Database schema diagnosis and repair
  - Calendar integration debugging (Google OAuth)
  - Analytics troubleshooting (zero data issue)
  - Excel import workflow documentation
  - Performance optimization strategies

---

**Author**: Based on hands-on debugging of production insurance CRM
**Specialization**: Next.js + Supabase + Insurance domain
**Use Case**: HealthSherpa agents, insurance brokers, ACA enrollment specialists
