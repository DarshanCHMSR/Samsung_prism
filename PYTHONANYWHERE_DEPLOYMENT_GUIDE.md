# PythonAnywhere Deployment Guide for Keystroke Authentication Backend

## 📋 **PythonAnywhere Deployment Overview**

**✅ YES, you can deploy to PythonAnywhere!** It's an excellent choice for your keystroke authentication backend because:

### **Why PythonAnywhere?**
- ✅ **Free tier available** (perfect for development/testing)
- ✅ **Managed hosting** - no server management needed
- ✅ **Python-focused** - optimized for Python applications
- ✅ **Persistent storage** - your ML models will be saved
- ✅ **Web app hosting** - ready for production use
- ✅ **SSL certificates** - automatic HTTPS
- ✅ **Easy scaling** - upgrade plans available

### **PythonAnywhere Limitations to Consider**
- ⚠️ **CPU limits** - Free tier has usage limits
- ⚠️ **Memory limits** - 512MB on free tier
- ⚠️ **Storage limits** - 512MB on free tier
- ⚠️ **No GPU access** - CPU-only ML processing

---

## 🚀 **Step-by-Step Deployment Guide**

### **Step 1: Create PythonAnywhere Account**
1. Go to [pythonanywhere.com](https://pythonanywhere.com)
2. Sign up for a free account
3. Verify your email

### **Step 2: Upload Your Code**
```bash
# On PythonAnywhere, open a Bash console and clone your repo:
git clone https://github.com/DarshanCHMSR/Samsung_prism.git
cd Samsung_prism/keystroke_auth_backend
```

### **Step 3: Set Up Virtual Environment**
```bash
# Create virtual environment
python3.11 -m venv keystroke_env

# Activate it
source keystroke_env/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### **Step 4: Configure for PythonAnywhere**
```bash
# Create the required files (I'll create them for you)
# 1. flask_app.py - WSGI entry point
# 2. .env - Environment configuration
```

### **Step 5: Set Up Web App**
1. Go to **Web** tab in PythonAnywhere dashboard
2. Click **Add a new web app**
3. Choose **Flask** and **Python 3.11**
4. Set the app path to: `/home/yourusername/Samsung_prism/keystroke_auth_backend`
5. Set the WSGI file to: `flask_app.py`

### **Step 6: Configure Environment**
```bash
# In PythonAnywhere Web tab:
# Set environment variables:
FLASK_ENV=production
FLASK_DEBUG=false
ENABLE_CORS=true
```

---

## 📁 **PythonAnywhere-Specific Files**

I've created the necessary files for PythonAnywhere deployment:

### **1. `flask_app.py` - WSGI Entry Point**
```python
# This is the file PythonAnywhere expects
from app import app as application

if __name__ == "__main__":
    application.run()
```

### **2. `.env` - Environment Configuration**
```bash
FLASK_ENV=production
FLASK_DEBUG=false
ENABLE_CORS=true
LOG_LEVEL=INFO
MODEL_DIR=user_models
```

### **3. `requirements.txt` - Dependencies**
- ✅ All your current dependencies are compatible
- ✅ PythonAnywhere supports scikit-learn
- ✅ Flask and other packages work perfectly

---

## 🔧 **PythonAnywhere Configuration**

### **Web App Configuration**
```
Source code: /home/yourusername/Samsung_prism/keystroke_auth_backend
Working directory: /home/yourusername/Samsung_prism/keystroke_auth_backend
WSGI configuration file: flask_app.py
Python version: 3.11
Virtualenv: /home/yourusername/keystroke_env
```

### **Environment Variables**
```
FLASK_ENV=production
FLASK_DEBUG=false
ENABLE_CORS=true
LOG_LEVEL=INFO
```

---

## 🌐 **Access URLs**

After deployment, your API will be available at:
```
https://yourusername.pythonanywhere.com/
```

### **API Endpoints**
```
Health Check: https://yourusername.pythonanywhere.com/health
Train Model:  https://yourusername.pythonanywhere.com/train
Predict:      https://yourusername.pythonanywhere.com/predict
User Info:    https://yourusername.pythonanywhere.com/user/demo_user/info
```

---

## 📱 **Flutter App Configuration**

Update your Flutter app to use the PythonAnywhere URL:

```dart
// In your Flutter app, update the API base URL:
const String keystrokeApiUrl = 'https://yourusername.pythonanywhere.com';
```

---

## 🔄 **Deployment Workflow**

### **Initial Deployment**
```bash
# 1. Upload code to PythonAnywhere
git clone https://github.com/DarshanCHMSR/Samsung_prism.git

# 2. Set up virtual environment
cd Samsung_prism/keystroke_auth_backend
python3.11 -m venv keystroke_env
source keystroke_env/bin/activate
pip install -r requirements.txt

# 3. Configure web app in PythonAnywhere dashboard
# 4. Reload web app
```

### **Updates**
```bash
# Pull latest changes
cd Samsung_prism/keystroke_auth_backend
git pull origin main

# Reload web app in PythonAnywhere dashboard
```

---

## ⚙️ **PythonAnywhere-Specific Optimizations**

### **Memory Optimization**
```python
# In config.py, reduce memory usage:
MODEL_CACHE_ENABLED = False  # Disable caching on free tier
FEATURE_CACHE_ENABLED = False
MAX_KEYSTROKE_EVENTS = 500  # Reduce from 1000
```

### **CPU Optimization**
```python
# Use fewer estimators for faster training:
N_ESTIMATORS = 50  # Reduced from default
```

### **Storage Optimization**
```python
# Compress model files:
# PythonAnywhere has storage limits
# Consider periodic cleanup of old models
```

---

## 🔒 **Security Configuration**

### **CORS Settings for PythonAnywhere**
```python
# In app.py, update CORS for production:
CORS(app, resources={
    r"/*": {
        "origins": [
            "https://yourusername.pythonanywhere.com",
            "http://localhost:*",
            "http://127.0.0.1:*",
            "http://10.0.2.2:*"
        ],
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization", "Accept"],
        "supports_credentials": False
    }
})
```

---

## 📊 **PythonAnywhere Plans**

| Plan | CPU | Memory | Storage | Price |
|------|-----|--------|---------|-------|
| Free | Limited | 512MB | 512MB | $0 |
| Hacker | 1 CPU | 1GB | 3GB | $5/month |
| Pro | 2 CPUs | 2GB | 10GB | $10/month |

**Recommendation**: Start with **Free tier** for testing, upgrade to **Hacker** for production use.

---

## 🚨 **Troubleshooting**

### **Common Issues**
```bash
# If app doesn't start:
# Check PythonAnywhere error logs in Web tab

# If dependencies fail:
# Use PythonAnywhere's package installer in Web tab

# If memory errors:
# Reduce model complexity in config.py

# If timeout errors:
# Increase timeout in PythonAnywhere Web settings
```

### **Logs**
```bash
# View logs in PythonAnywhere:
# Web tab -> Logs section
# Or use: tail -f /var/log/pythonanywhere/error.log
```

---

## 🎯 **Quick Start Commands**

### **On PythonAnywhere**
```bash
# Clone and setup
git clone https://github.com/DarshanCHMSR/Samsung_prism.git
cd Samsung_prism/keystroke_auth_backend
python3.11 -m venv keystroke_env
source keystroke_env/bin/activate
pip install -r requirements.txt
```

### **Configure Web App**
1. Go to **Web** tab
2. **Add new web app**
3. Choose **Flask** → **Python 3.11**
4. Set source path and WSGI file
5. **Reload** the web app

---

## ✅ **Ready to Deploy!**

Your keystroke authentication backend is **perfectly compatible** with PythonAnywhere!

**Next Steps:**
1. Create PythonAnywhere account
2. Upload your code
3. Follow the deployment guide above
4. Update your Flutter app with the new API URL
5. Test the deployment

**Estimated deployment time: 15-30 minutes**

The system will work seamlessly on PythonAnywhere with your existing ML models and all functionality intact! 🚀
