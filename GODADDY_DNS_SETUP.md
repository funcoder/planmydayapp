# GoDaddy DNS Configuration for planmyday.me

## DNS Records to Add/Update in GoDaddy

Follow these steps to configure your domain to point to your Fly.io app:

### 1. Log into GoDaddy
- Go to https://www.godaddy.com
- Sign in to your account
- Navigate to "My Products" → "Domains"
- Find "planmyday.me" and click "DNS" or "Manage DNS"

### 2. Update/Add DNS Records

Delete any existing A or AAAA records for @ and www, then add these:

#### For the root domain (planmyday.me):
| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | @ | 66.241.125.91 | 600 |
| AAAA | @ | 2a09:8280:1::90:f262:0 | 600 |

#### For the www subdomain (www.planmyday.me):
| Type | Name | Value | TTL |
|------|------|-------|-----|
| CNAME | www | planmyday-app.fly.dev | 600 |

### 3. Remove Conflicting Records
- Delete any existing A records pointing to other IPs (like 104.16.36.105)
- Delete any CNAME records for @ (root domain can't have CNAME)
- Keep any MX records for email if you have them

### 4. Save Changes
- Click "Save" after making all changes
- DNS propagation can take 5-48 hours, but typically happens within 30 minutes

## Verification Steps

After updating DNS, you can verify the configuration:

1. Check DNS propagation:
   ```bash
   dig planmyday.me
   dig www.planmyday.me
   ```

2. Check certificate status on Fly:
   ```bash
   fly certs show planmyday.me
   fly certs show www.planmyday.me
   ```

3. Test the domain (after DNS propagates):
   ```bash
   curl -I https://planmyday.me
   curl -I https://www.planmyday.me
   ```

## Current Status
- ✅ SSL certificates created on Fly.io for both domains
- ⏳ Waiting for DNS configuration in GoDaddy
- ⏳ DNS propagation (after you update GoDaddy)

## Notes
- The IPv6 address (AAAA record) is optional but recommended
- If GoDaddy doesn't support IPv6, just use the A record
- The certificate will automatically activate once DNS points correctly