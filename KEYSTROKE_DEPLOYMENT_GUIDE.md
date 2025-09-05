# 🚀 Keystroke Authentication Backend - Deployment Guide

## 📋 **Overview**

The Keystroke Authentication Backend is a Flask-based REST API that provides machine learning-powered keystroke dynamics authentication. This guide covers multiple deployment options from local development to production cloud deployment.

---

## 🏗️ **Project Structure Analysis**

```
keystroke_auth_backend/
├── app.py                      # Main Flask application
├── config.py                   # Configuration management
├── requirements.txt            # Python dependencies
├── setup.py                    # Setup script
├── run_server.bat             # Windows startup script
├── run_server.sh              # Linux/Mac startup script
├── user_models/                # ML model storage directory
├── test_api.py                 # API testing utilities
└── validate.py                 # Model validation tools
```

### **Key Components**
- **Flask Web Framework**: REST API server
- **Scikit-learn**: Machine learning with IsolationForest
- **Joblib**: Model serialization
- **NumPy**: Numerical computations
- **CORS Support**: Cross-origin requests

---

## 🔧 **Deployment Options**

### **Option 1: Local Development (Current Setup)**

#### **Quick Start**
```bash
cd keystroke_auth_backend

# Create virtual environment
python -m venv venv

# Activate environment
venv\Scripts\activate  # Windows
# or
source venv/bin/activate  # Linux/Mac

# Install dependencies
pip install -r requirements.txt

# Run the server
python app.py
```

#### **Access Points**
- **Local**: `http://localhost:5000`
- **Network**: `http://YOUR_IP:5000`
- **Android Emulator**: `http://10.0.2.2:5000`

---

### **Option 2: Docker Containerization**

#### **Create Dockerfile**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create model directory
RUN mkdir -p user_models

# Expose port
EXPOSE 5000

# Set environment variables
ENV FLASK_ENV=production
ENV FLASK_HOST=0.0.0.0
ENV FLASK_PORT=5000

# Run the application
CMD ["python", "app.py"]
```

#### **Create docker-compose.yml**
```yaml
version: '3.8'

services:
  keystroke-auth:
    build: .
    ports:
      - "5000:5000"
    volumes:
      - ./user_models:/app/user_models
    environment:
      - FLASK_ENV=production
      - FLASK_DEBUG=false
    restart: unless-stopped
```

#### **Deploy with Docker**
```bash
# Build and run
docker-compose up -d

# Check logs
docker-compose logs -f keystroke-auth

# Stop the service
docker-compose down
```

---

### **Option 3: Cloud Deployment - Heroku**

#### **Create Procfile**
```
web: python app.py
```

#### **Create runtime.txt**
```
python-3.11.5
```

#### **Deploy Steps**
```bash
# Install Heroku CLI
# Create Heroku app
heroku create your-keystroke-auth-app

# Set environment variables
heroku config:set FLASK_ENV=production
heroku config:set FLASK_DEBUG=false

# Deploy
git push heroku main
```

#### **Heroku Environment Variables**
```bash
heroku config:set FLASK_HOST=0.0.0.0
heroku config:set FLASK_PORT=5000
heroku config:set SECRET_KEY=your-production-secret-key
```

---

### **Option 4: Cloud Deployment - AWS EC2**

#### **Launch EC2 Instance**
```bash
# Choose Ubuntu 22.04 LTS
# t2.micro (free tier) or t3.small for better performance
# Security group: Allow SSH (22) and HTTP (5000)
```

#### **Server Setup**
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Python and pip
sudo apt install python3 python3-pip python3-venv -y

# Install nginx (optional, for production)
sudo apt install nginx -y
```

#### **Application Deployment**
```bash
# Clone your repository
git clone https://github.com/yourusername/Samsung_prism.git
cd Samsung_prism/keystroke_auth_backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Create systemd service
sudo nano /etc/systemd/system/keystroke-auth.service
```

#### **Create Systemd Service**
```ini
[Unit]
Description=Keystroke Authentication Backend
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/Samsung_prism/keystroke_auth_backend
Environment=FLASK_ENV=production
Environment=FLASK_HOST=0.0.0.0
Environment=FLASK_PORT=5000
ExecStart=/home/ubuntu/Samsung_prism/keystroke_auth_backend/venv/bin/python app.py
Restart=always

[Install]
WantedBy=multi-user.target
```

#### **Enable and Start Service**
```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable service
sudo systemctl enable keystroke-auth

# Start service
sudo systemctl start keystroke-auth

# Check status
sudo systemctl status keystroke-auth

# View logs
sudo journalctl -u keystroke-auth -f
```

---

### **Option 5: Cloud Deployment - Google Cloud Run**

#### **Create Dockerfile** (same as Docker option)

#### **Deploy to Cloud Run**
```bash
# Build and push to Google Container Registry
gcloud builds submit --tag gcr.io/PROJECT-ID/keystroke-auth

# Deploy to Cloud Run
gcloud run deploy keystroke-auth \
  --image gcr.io/PROJECT-ID/keystroke-auth \
  --platform managed \
  --port 5000 \
  --allow-unauthenticated \
  --set-env-vars FLASK_ENV=production
```

---

### **Option 6: Cloud Deployment - Azure App Service**

#### **Create Azure Web App**
```bash
# Create resource group
az group create --name keystroke-auth-rg --location eastus

# Create app service plan
az appservice plan create --name keystroke-auth-plan --resource-group keystroke-auth-rg --sku B1

# Create web app
az webapp create --name your-keystroke-auth-app --resource-group keystroke-auth-rg --plan keystroke-auth-plan --runtime "PYTHON:3.11"
```

#### **Configure Deployment**
```bash
# Set environment variables
az webapp config appsettings set --name your-keystroke-auth-app --resource-group keystroke-auth-rg --setting FLASK_ENV=production

# Deploy using Git
az webapp deployment source config-local-git --name your-keystroke-auth-app --resource-group keystroke-auth-rg
```

---

## ⚙️ **Configuration Management**

### **Environment Variables**
```bash
# Server Configuration
FLASK_HOST=0.0.0.0
FLASK_PORT=5000
FLASK_DEBUG=false
FLASK_ENV=production

# Security
SECRET_KEY=your-production-secret-key

# Model Configuration
MIN_SAMPLES=5
CONTAMINATION=0.1
RANDOM_STATE=42

# Logging
LOG_LEVEL=WARNING

# CORS (disable in production)
ENABLE_CORS=false
```

### **Production Configuration**
```python
# config.py - Production settings
class ProductionConfig(Config):
    DEBUG = False
    LOG_LEVEL = 'WARNING'
    ENABLE_CORS = False
    SECRET_KEY = os.environ.get('SECRET_KEY', 'change-this-in-production')
    MODEL_CACHE_ENABLED = True
    FEATURE_CACHE_ENABLED = True
```

---

## 🔒 **Security Considerations**

### **Production Security**
```python
# Disable debug mode
DEBUG = False

# Use strong secret key
SECRET_KEY = os.environ.get('SECRET_KEY')

# Configure CORS properly
CORS(app, origins=['https://yourdomain.com'])

# Add rate limiting (consider Flask-Limiter)
# Add authentication middleware
# Use HTTPS in production
```

### **Data Security**
- **Model Files**: Store in secure directory with proper permissions
- **User Data**: Encrypt sensitive keystroke data if required
- **API Keys**: Never commit secrets to version control
- **Network Security**: Use HTTPS and proper firewall rules

---

## 📊 **Monitoring & Maintenance**

### **Health Checks**
```bash
# Health endpoint
GET /health

# Returns system status and model information
```

### **Logging**
```python
# Configure structured logging
logging.basicConfig(
    level=logging.WARNING,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('keystroke_auth.log'),
        logging.StreamHandler()
    ]
)
```

### **Backup Strategy**
```bash
# Backup user models regularly
tar -czf user_models_backup_$(date +%Y%m%d).tar.gz user_models/

# Store backups securely
# Consider automated backup scripts
```

---

## 🚀 **Recommended Deployment Strategy**

### **For Development**
```bash
# Local deployment with hot reload
python app.py
```

### **For Production**
```bash
# Docker + Cloud provider (recommended)
docker-compose up -d

# Or direct server deployment
sudo systemctl start keystroke-auth
```

### **For Enterprise**
```bash
# Kubernetes cluster
kubectl apply -f keystroke-auth-deployment.yaml

# Or cloud-managed service
# Heroku, Azure App Service, Google Cloud Run
```

---

## 🔧 **Troubleshooting**

### **Common Issues**
```bash
# Port already in use
sudo lsof -i :5000
sudo kill -9 <PID>

# Permission errors
sudo chown -R ubuntu:ubuntu /home/ubuntu/Samsung_prism

# Memory issues
# Increase EC2 instance size or add swap file
```

### **Performance Optimization**
```python
# Enable model caching
MODEL_CACHE_ENABLED = True

# Configure Gunicorn for production
# pip install gunicorn
# gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

---

## 📈 **Scaling Considerations**

### **Horizontal Scaling**
- **Load Balancer**: Distribute requests across multiple instances
- **Session Management**: Handle user sessions across instances
- **Shared Storage**: Use cloud storage for model files

### **Database Integration**
- **Model Storage**: Consider database storage for larger deployments
- **Caching**: Redis for model caching
- **Monitoring**: Application performance monitoring

---

## 🎯 **Quick Deployment Commands**

### **Local Development**
```bash
cd keystroke_auth_backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

### **Docker Deployment**
```bash
docker build -t keystroke-auth .
docker run -p 5000:5000 keystroke-auth
```

### **Cloud Deployment (Heroku)**
```bash
heroku create your-app-name
git push heroku main
```

---

*This deployment guide provides multiple options from simple local development to enterprise-grade cloud deployment. Choose the option that best fits your infrastructure requirements and scalability needs.*
