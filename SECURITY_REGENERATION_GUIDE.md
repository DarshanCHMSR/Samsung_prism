# SECURITY REGENERATION GUIDE
# ================================

Your repository contained exposed credentials. Follow these steps IMMEDIATELY:

## 1. REVOKE ALL EXPOSED CREDENTIALS

### Firebase Project:
1. Go to https://console.firebase.google.com/
2. Select your project: samsung-prism-banking-app
3. Go to Project Settings → Service Accounts
4. Delete the current service account: firebase-adminsdk-fbsvc@samsung-prism-banking-app.iam.gserviceaccount.com
5. Create a new service account
6. Generate new private key

### Google Cloud Console:
1. Go to https://console.cloud.google.com/
2. Select your project
3. Go to APIs & Services → Credentials
4. Delete all existing API keys:
   - AIzaSyByf_qy7ErrehJrhOtlHA_-qphdhDFwJjI
   - AIzaSyCT-bZcAuGwoqemR4O-QDjzMXEiGBrQ5xQ
   - AIzaSyAh7CQfljsY9c7jfRBzbWcV8GRCmV630CY
   - AIzaSyB2LjYo640qsrQQb8GHHRUMD1VjQDEpPC8
5. Create new API keys with proper restrictions

### Gemini API:
1. Go to https://makersuite.google.com/app/apikey
2. Delete the exposed key: AIzaSyB2LjYo640qsrQQb8GHHRUMD1VjQDEpPC8
3. Generate a new API key

## 2. REMOVE FILES FROM GIT HISTORY

Run these commands to remove sensitive files from git history:

```bash
# Remove sensitive files from git history
git filter-branch --force --index-filter \
"git rm --cached --ignore-unmatch samsung_prism/lib/firebase_options.dart" \
--prune-empty --tag-name-filter cat -- --all

git filter-branch --force --index-filter \
"git rm --cached --ignore-unmatch samsung_prism/android/app/google-services.json" \
--prune-empty --tag-name-filter cat -- --all

git filter-branch --force --index-filter \
"git rm --cached --ignore-unmatch agent_development_kit/.env" \
--prune-empty --tag-name-filter cat -- --all

git filter-branch --force --index-filter \
"git rm --cached --ignore-unmatch agent_development_kit/config/samsung-prism-banking-app-firebase-adminsdk.json" \
--prune-empty --tag-name-filter cat -- --all

# Force push to remote (WARNING: This rewrites history)
git push origin --force --all
git push origin --force --tags
```

## 3. REGENERATE CONFIGURATION FILES

### Create new firebase_options.dart:
1. Run: flutter packages pub run flutter_fire_cli:generate
2. Or manually create from firebase_options.dart.example

### Create new google-services.json:
1. Download from Firebase Console → Project Settings → General → Your apps

### Create new .env files:
1. Copy from .env.example
2. Add your new API keys

### Create new Firebase service account:
1. Download new JSON file from Firebase Console
2. Save as samsung-prism-banking-app-firebase-adminsdk.json
3. Update GOOGLE_APPLICATION_CREDENTIALS path

## 4. VERIFY SECURITY

After completing the above:
1. Scan repository for any remaining secrets
2. Test that old credentials no longer work
3. Verify new credentials work properly
4. Monitor for any unauthorized access

## 5. SECURITY BEST PRACTICES GOING FORWARD

1. Never commit .env files
2. Use environment variables for sensitive data
3. Add all credential files to .gitignore
4. Use example files for documentation
5. Regularly rotate API keys
6. Use least-privilege access for service accounts
7. Monitor API usage for unauthorized access

## IMMEDIATE ACTIONS COMPLETED:
✅ Added comprehensive .gitignore
✅ Created firebase_options.dart.example
✅ Created this security guide

## ACTIONS YOU MUST COMPLETE:
❌ Revoke all exposed API keys
❌ Create new Firebase service accounts  
❌ Generate new API keys with restrictions
❌ Remove sensitive files from git history
❌ Update all configuration files with new credentials
