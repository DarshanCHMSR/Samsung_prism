# FIREBASE SERVICE ACCOUNT PERMISSIONS FIX
# ==========================================

## Problem: 403 Missing or insufficient permissions

The new service account you created doesn't have the right permissions to access Firestore.

## Solution Steps:

### Method 1: Google Cloud Console (Recommended)

1. Go to https://console.cloud.google.com/
2. Select your project: samsung-prism-banking-app
3. Navigate to IAM & Admin → IAM
4. Find your service account: firebase-adminsdk-***@samsung-prism-banking-app.iam.gserviceaccount.com
5. Click the edit (pencil) icon
6. Add these roles:
   - **Cloud Datastore User** (for Firestore read/write)
   - **Firebase Admin** (for full Firebase access)
   - **Service Account Token Creator** (for authentication)

### Method 2: Firebase Console (Alternative)

1. Go to https://console.firebase.google.com/
2. Select your project: samsung-prism-banking-app  
3. Go to Project Settings → Service Accounts
4. Click "Manage service account permissions" 
5. Add the same roles as above

### Method 3: Command Line (If you have gcloud CLI)

```bash
# Replace YOUR_SERVICE_ACCOUNT_EMAIL with your actual service account email
PROJECT_ID="samsung-prism-banking-app"
SERVICE_ACCOUNT="firebase-adminsdk-xxxxx@samsung-prism-banking-app.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/datastore.user"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/firebase.admin"
```

## Required Permissions for Samsung Prism Multi-Agent System:

- **Cloud Datastore User**: Read/write access to Firestore collections
- **Firebase Admin**: Full access to Firebase services
- **Service Account Token Creator**: For internal authentication

## After Adding Permissions:

1. Wait 1-2 minutes for permissions to propagate
2. Restart your agent development kit:
   ```bash
   cd agent_development_kit
   python main.py
   ```

## Verification:

You should see:
```
✅ Firebase connection test passed. Found X collections.
```

Instead of:
```
❌ Firebase connection test failed: 403 Missing or insufficient permissions.
```
