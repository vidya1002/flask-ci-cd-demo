# 🚀 Python Flask CI/CD Deployment on AWS EC2 with Nginx & Gunicorn

## 📋 Project Overview

This project demonstrates how to build, test, and deploy a **Flask web application** (built using **Python**) on an **Amazon Linux EC2** instance. It uses **Nginx** as a reverse proxy and **Gunicorn** as the WSGI application server. The project follows a step-by-step CI/CD pipeline powered by **GitHub Actions** for automated testing and deployment.

🔗 **GitHub Repository**: [flask-ci-cd-demo](https://github.com/vidya1002/flask-ci-cd-demo)

---

## 📂 Project Structure

```
flask-ci-cd-demo/
│
├── .github/
│   └── workflows/
│       └── ci-cd.yml          # GitHub Actions CI/CD Workflow
│
├── deployment/
│   ├── nginx.conf            # Nginx Configuration
│   ├── gunicorn.service      # Gunicorn Systemd Service
│   └── deployment.sh         # Automated EC2 Setup Script
│
├── app.py                    # Flask Application (Python)
├── requirements.txt          # Python Dependencies (Flask & pytest)
├── test_app.py               # Unit Tests (Python)
└── README.md                 # Project Documentation
```

---

## 🛠️ Step-by-Step Development Process

### 1️⃣ Create and Run the Flask Application (`app.py`)

```python
from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return "Hello, World!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

#### Run the Application Locally
```bash
python app.py
```
Access the application at: `http://127.0.0.1:5000`

---

### 2️⃣ Install Dependencies (`requirements.txt`)

```txt
Flask==2.3.2
pytest==7.4.0
```

#### Install Dependencies
```bash
pip install -r requirements.txt
```

---

### 3️⃣ Initialize Git and Push to GitHub
```bash
git init
git add .
git commit -m "Initial commit: Added Flask app and requirements.txt"
git branch -M main
git remote add origin https://github.com/vidya1002/flask-ci-cd-demo.git
git push -u origin main
```

---

### 4️⃣ Set Up GitHub Actions CI/CD Workflow

Create a `.github/workflows/ci-cd.yml` file:

```yaml
name: Flask CI/CD Pipeline

on:
  push:
    branches:
      - main

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
      - name: Run tests
        run: |
          pytest test_app.py

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      - name: Deploy to AWS EC2
        run: |
          ssh -o StrictHostKeyChecking=no -i ${{ secrets.SSH_KEY }} ec2-user@${{ secrets.EC2_IP }} 'bash -s' < deployment/deployment.sh
```

---

### 5️⃣ Add Unit Tests (`test_app.py`)

```python
import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_home_page(client):
    response = client.get('/')
    assert response.status_code == 200
    assert b"Hello, World!" in response.data
```

#### Run Tests Locally
```bash
pytest test_app.py
```

---

### 6️⃣ Deploy to AWS EC2 with Nginx & Gunicorn

#### Connect to EC2 Instance
```bash
ssh -i your-key.pem ec2-user@your-ec2-public-ip
```

#### Install Nginx
```bash
sudo yum install nginx -y
```

#### Configure Nginx (`/etc/nginx/conf.d/flask-app.conf`)
```nginx
server {
    listen 80;
    server_name your-ec2-public-ip;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

#### Start and Enable Nginx
```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```

#### Install Gunicorn
```bash
pip install gunicorn
```

#### Configure Gunicorn (`/etc/systemd/system/gunicorn.service`)
```ini
[Unit]
Description=Gunicorn instance to serve Flask app
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=/home/ec2-user/flask-ci-cd-demo
ExecStart=/usr/local/bin/gunicorn --workers 3 --bind 127.0.0.1:8000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
```

#### Start and Enable Gunicorn
```bash
sudo systemctl start gunicorn
sudo systemctl enable gunicorn
```

---

### 📌 Useful Commands

#### Restart Services
```bash
sudo systemctl restart nginx
tsudo systemctl restart gunicorn
```

#### Check Logs
```bash
sudo journalctl -u gunicorn --no-pager --lines=50
sudo journalctl -u nginx --no-pager --lines=50
```

#### Reload Nginx Configuration
```bash
sudo nginx -t  # Test configuration
sudo systemctl reload nginx
```

---

## ✅ Expected Output

After successful deployment, visit `http://your-ec2-public-ip` and you should see:

```
Hello, World!
```

Sample Response:
```json
{
  "message": "Hello, World!"
}
```

---

## 📝 Author
- **Vidyashree K J** - *Developer & Maintainer*
  - 🔗 GitHub: [vidya1002](https://github.com/vidya1002)

🚀 **Happy Coding & Deployment!** 🔥

