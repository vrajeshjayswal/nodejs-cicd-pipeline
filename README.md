# Node.js Backend API - AWS CI/CD Pipeline

A complete CI/CD pipeline implementation for a Node.js backend API using GitHub, AWS CodeBuild, AWS CodePipeline, and EC2.

## 📋 Table of Contents
- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Step-by-Step Implementation](#step-by-step-implementation)
- [Testing the Pipeline](#testing-the-pipeline)
- [Troubleshooting](#troubleshooting)

## 🎯 Project Overview

This project demonstrates a complete CI/CD pipeline for deploying a Node.js Express API to AWS EC2 using:
- **GitHub**: Source code repository
- **AWS CodeBuild**: Build and test automation
- **AWS CodePipeline**: CI/CD orchestration
- **AWS CodeDeploy**: Deployment automation
- **Amazon EC2**: Application hosting

## 🏗️ Architecture

```
GitHub → CodePipeline → CodeBuild → CodeDeploy → EC2
```

1. Code is pushed to GitHub repository
2. CodePipeline detects the change automatically
3. CodeBuild downloads code, runs tests, and creates artifacts
4. CodeDeploy deploys the artifact to EC2 instance
5. Application runs on EC2 with PM2 process manager

## ✅ Prerequisites

- AWS Account with appropriate permissions
- GitHub Account
- Basic knowledge of AWS Console
- Git installed locally

---

## 🚀 Step-by-Step Implementation

### **PHASE 1: Setup GitHub Repository**

#### Step 1.1: Create GitHub Repository
1. Go to [GitHub](https://github.com)
2. Click **"New repository"** button
3. Enter repository name: `nodejs-cicd-pipeline`
4. Choose **Public** or **Private**
5. DO NOT initialize with README (we have our own files)
6. Click **"Create repository"**

#### Step 1.2: Push Local Code to GitHub
1. Open terminal in your project directory
2. Run the following commands:
```bash
git init
git add .
git commit -m "Initial commit - Node.js API with CI/CD setup"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/nodejs-cicd-pipeline.git
git push -u origin main
```

#### Step 1.3: Create GitHub Personal Access Token
1. Go to GitHub → Click your profile → **Settings**
2. Scroll down and click **"Developer settings"** (left sidebar)
3. Click **"Personal access tokens"** → **"Tokens (classic)"**
4. Click **"Generate new token"** → **"Generate new token (classic)"**
5. Give it a name: `AWS CodePipeline Access`
6. Set expiration as needed
7. Select scopes:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `admin:repo_hook` (Full control of repository hooks)
8. Click **"Generate token"**
9. **IMPORTANT**: Copy the token immediately (you won't see it again!)

---

### **PHASE 2: Setup EC2 Instance**

#### Step 2.1: Launch EC2 Instance
1. Go to AWS Console → Search for **"EC2"** → Click **EC2**
2. Click **"Launch Instance"** button
3. Configure the instance:

**Name and tags:**
- Name: `nodejs-api-server`

**Application and OS Images (Amazon Machine Image):**
- Select **Amazon Linux 2023 AMI** (Free tier eligible)

**Instance type:**
- Select **t2.micro** (Free tier eligible)

**Key pair (login):**
- Click **"Create new key pair"**
- Name: `nodejs-api-key`
- Key pair type: **RSA**
- Private key file format: **.pem** (for Mac/Linux) or **.ppk** (for Windows/PuTTY)
- Click **"Create key pair"** (it will download automatically)

**Network settings:**
- Click **"Edit"**
- Auto-assign public IP: **Enable**
- Firewall (security groups): **Create security group**
- Security group name: `nodejs-api-sg`
- Description: `Security group for Node.js API`
- Add the following rules:
  
  **Inbound Rules:**
  1. **SSH**
     - Type: SSH
     - Port: 22
     - Source: My IP (or Anywhere for testing - 0.0.0.0/0)
  
  2. **HTTP**
     - Type: HTTP
     - Port: 80
     - Source: Anywhere (0.0.0.0/0)
  
  3. **Custom TCP**
     - Type: Custom TCP
     - Port: 3000
     - Source: Anywhere (0.0.0.0/0)
     - Description: Node.js API port

**Configure storage:**
- 8 GB gp3 (default is fine)

**Advanced details:**
- Expand this section
- Scroll down to **IAM instance profile**
- Leave it blank for now (we'll create and attach it later)

4. Click **"Launch instance"**
5. Wait for instance state to be **"Running"**
6. Note down the **Public IPv4 address**

#### Step 2.2: Create IAM Role for EC2
1. Go to AWS Console → Search for **"IAM"** → Click **IAM**
2. Click **"Roles"** in left sidebar
3. Click **"Create role"**
4. Select trusted entity:
   - **Trusted entity type**: AWS service
   - **Use case**: EC2
   - Click **"Next"**
5. Add permissions - Search and select these policies:
   - ✅ `AmazonEC2RoleforAWSCodeDeploy`
   - ✅ `AmazonS3ReadOnlyAccess`
   - Click **"Next"**
6. Name the role:
   - Role name: `EC2-CodeDeploy-Role`
   - Description: `Allows EC2 instances to call CodeDeploy and S3`
7. Click **"Create role"**

#### Step 2.3: Attach IAM Role to EC2 Instance
1. Go back to **EC2 Dashboard**
2. Select your instance (`nodejs-api-server`)
3. Click **"Actions"** → **"Security"** → **"Modify IAM role"**
4. Select **`EC2-CodeDeploy-Role`** from dropdown
5. Click **"Update IAM role"**

#### Step 2.4: Install CodeDeploy Agent on EC2
1. Connect to your EC2 instance using SSH:
```bash
ssh -i "nodejs-api-key.pem" ec2-user@YOUR_EC2_PUBLIC_IP
```

2. Once connected, run these commands:
```bash
# Update system
sudo yum update -y

# Install Ruby (required for CodeDeploy agent)
sudo yum install ruby wget -y

# Download CodeDeploy agent
cd /home/ec2-user
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install

# Make it executable
chmod +x ./install

# Install CodeDeploy agent
sudo ./install auto

# Check CodeDeploy agent status
sudo service codedeploy-agent status
```

3. Expected output: `The AWS CodeDeploy agent is running`

4. Enable CodeDeploy agent to start on boot:
```bash
sudo systemctl enable codedeploy-agent
```

---

### **PHASE 3: Setup AWS CodeDeploy**

#### Step 3.1: Create IAM Role for CodeDeploy
1. Go to **IAM** → **Roles** → **"Create role"**
2. Select trusted entity:
   - **Trusted entity type**: AWS service
   - **Use case**: CodeDeploy
   - Click **"Next"**
3. Permissions are automatically added (`AWSCodeDeployRole`)
4. Click **"Next"**
5. Name the role:
   - Role name: `CodeDeploy-Service-Role`
   - Description: `Allows CodeDeploy to call AWS services`
6. Click **"Create role"**

#### Step 3.2: Create CodeDeploy Application
1. Go to AWS Console → Search for **"CodeDeploy"** → Click **CodeDeploy**
2. Click **"Applications"** in left sidebar
3. Click **"Create application"**
4. Configure:
   - Application name: `nodejs-api-app`
   - Compute platform: **EC2/On-premises**
5. Click **"Create application"**

#### Step 3.3: Create Deployment Group
1. In your application page, click **"Create deployment group"**
2. Configure:

**Deployment group name:**
- Name: `nodejs-api-deployment-group`

**Service role:**
- Select **`CodeDeploy-Service-Role`** (created in Step 3.1)

**Deployment type:**
- Select **In-place**

**Environment configuration:**
- Select **Amazon EC2 instances**
- Add tag:
  - Key: `Name`
  - Value: `nodejs-api-server`
  
  (This should match your EC2 instance name tag)

**Agent configuration with AWS Systems Manager:**
- Leave default: **Now and schedule updates**

**Deployment settings:**
- Deployment configuration: **CodeDeployDefault.AllAtOnce**

**Load balancer:**
- Uncheck **"Enable load balancing"** (not needed for this demo)

3. Click **"Create deployment group"**

---

### **PHASE 4: Setup AWS CodeBuild**

#### Step 4.1: Create IAM Role for CodeBuild (Optional - can be auto-created)
We'll let CodeBuild create this automatically in the next step.

#### Step 4.2: Create CodeBuild Project
1. Go to AWS Console → Search for **"CodeBuild"** → Click **CodeBuild**
2. Click **"Create build project"**
3. Configure:

**Project configuration:**
- Project name: `nodejs-api-build`
- Description: `Build project for Node.js API`

**Source:**
- Source provider: **GitHub**
- Repository: **Connect using OAuth** or **Use a personal access token**
  
  If using OAuth:
  - Click **"Connect to GitHub"**
  - Authorize AWS CodeBuild
  - Select your repository
  
  If using Personal Access Token:
  - Click **"GitHub personal access token"**
  - Paste your GitHub token from Step 1.3
  - Click **"Save token"**
- Repository: Select **`Repository in my GitHub account`**
- GitHub repository: Enter your repository URL or select from list

**Webhook (optional):**
- Leave unchecked (CodePipeline will trigger builds)

**Environment:**
- Environment image: **Managed image**
- Operating system: **Amazon Linux 2**
- Runtime(s): **Standard**
- Image: **aws/codebuild/amazonlinux2-x86_64-standard:5.0** (or latest)
- Image version: **Always use the latest image**
- Environment type: **Linux**
- Privileged: Leave unchecked
- Service role: **New service role**
- Role name: `codebuild-nodejs-api-service-role` (auto-generated)

**Buildspec:**
- Build specifications: **Use a buildspec file**
- Buildspec name: `buildspec.yml` (default)

**Artifacts:**
- Type: **Amazon S3**
- Bucket name: We'll create this in CodePipeline
- Name: Leave default
- For now, select **No artifacts** (CodePipeline will handle this)

**Logs:**
- CloudWatch logs: **Enabled** (default)
- Group name: Leave default
- Stream name: Leave default

4. Click **"Create build project"**

---

### **PHASE 5: Setup AWS CodePipeline**

#### Step 5.1: Create CodePipeline
1. Go to AWS Console → Search for **"CodePipeline"** → Click **CodePipeline**
2. Click **"Create pipeline"**

**Step 1: Choose pipeline settings**
- Pipeline name: `nodejs-api-pipeline`
- Service role: **New service role**
- Role name: Auto-generated (`AWSCodePipelineServiceRole-...`)
- Allow AWS CodePipeline to create a service role: ✅ Checked
- Advanced settings:
  - Artifact store: **Default location**
  - Encryption key: **Default AWS Managed Key**
- Click **"Next"**

**Step 2: Add source stage**
- Source provider: **GitHub (Version 2)**
- Click **"Connect to GitHub"**
  - Connection name: `github-connection`
  - Click **"Connect to GitHub"**
  - Click **"Authorize AWS Connector for GitHub"**
  - Click **"Connect"**
- Repository name: Select your repository (e.g., `YOUR_USERNAME/nodejs-cicd-pipeline`)
- Branch name: `main`
- Change detection options: **Start the pipeline on source code change** (✅ Checked)
- Output artifact format: **CodePipeline default**
- Click **"Next"**

> **Note**: If GitHub Version 2 is not available, use **GitHub (Version 1)** and use your personal access token.

**Step 3: Add build stage**
- Build provider: **AWS CodeBuild**
- Region: Your region (e.g., `us-east-1`)
- Project name: **`nodejs-api-build`** (select from dropdown)
- Build type: **Single build**
- Click **"Next"**

**Step 4: Add deploy stage**
- Deploy provider: **AWS CodeDeploy**
- Region: Your region (e.g., `us-east-1`)
- Application name: **`nodejs-api-app`** (select from dropdown)
- Deployment group: **`nodejs-api-deployment-group`** (select from dropdown)
- Click **"Next"**

**Step 5: Review**
- Review all settings
- Click **"Create pipeline"**

#### Step 5.2: Pipeline Execution
The pipeline will automatically start executing. You'll see three stages:
1. **Source**: Fetching code from GitHub ✅
2. **Build**: Building and testing with CodeBuild ⏳
3. **Deploy**: Deploying to EC2 with CodeDeploy ⏳

---

### **PHASE 6: Configure IAM Permissions (if needed)**

If you encounter permission errors, ensure these policies are attached:

#### For CodeBuild Role:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:GetObjectVersion"
            ],
            "Resource": "arn:aws:s3:::codepipeline-*/*"
        }
    ]
}
```

#### For EC2 Role:
Ensure `EC2-CodeDeploy-Role` has:
- `AmazonEC2RoleforAWSCodeDeploy`
- `AmazonS3ReadOnlyAccess`

---

## 🧪 Testing the Pipeline

### Test 1: Initial Deployment
1. Check CodePipeline execution status
2. All three stages should succeed (green checkmark)
3. Access your application:
   - Open browser: `http://YOUR_EC2_PUBLIC_IP:3000`
   - You should see: `{"message":"Welcome to Node.js Backend API","version":"1.0.0","status":"running"}`

### Test 2: Test API Endpoints
```bash
# Health check
curl http://YOUR_EC2_PUBLIC_IP:3000/api/health

# Get users
curl http://YOUR_EC2_PUBLIC_IP:3000/api/users

# Create user
curl -X POST http://YOUR_EC2_PUBLIC_IP:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com"}'
```

### Test 3: Trigger CI/CD Pipeline
1. Make a change to your code locally:
```javascript
// Edit server.js - change version
res.json({
  message: 'Welcome to Node.js Backend API - Updated!',
  version: '2.0.0',
  status: 'running'
});
```

2. Commit and push:
```bash
git add .
git commit -m "Update API version to 2.0.0"
git push origin main
```

3. Go to CodePipeline console
4. Watch the pipeline execute automatically
5. After successful deployment, verify the change:
```bash
curl http://YOUR_EC2_PUBLIC_IP:3000
```

---

## 🔍 Monitoring and Logs

### View CodeBuild Logs:
1. Go to **CodeBuild** → **Build projects**
2. Click your project → **Build history**
3. Click on a build → **Build logs**

### View CodeDeploy Logs on EC2:
```bash
# SSH to EC2
ssh -i "nodejs-api-key.pem" ec2-user@YOUR_EC2_PUBLIC_IP

# View CodeDeploy agent logs
sudo tail -f /var/log/aws/codedeploy-agent/codedeploy-agent.log

# View deployment logs
sudo tail -f /opt/codedeploy-agent/deployment-root/deployment-logs/codedeploy-agent-deployments.log

# View application logs
pm2 logs nodejs-app
```

### Check Application Status:
```bash
# SSH to EC2
ssh -i "nodejs-api-key.pem" ec2-user@YOUR_EC2_PUBLIC_IP

# Check PM2 status
pm2 status

# Check if port 3000 is listening
sudo netstat -tulpn | grep 3000

# Manual test
curl localhost:3000/api/health
```

---

## 🐛 Troubleshooting

### Issue 1: CodeDeploy Agent Not Running
**Solution:**
```bash
sudo service codedeploy-agent start
sudo service codedeploy-agent status
```

### Issue 2: Deployment Fails at ApplicationStop
**Solution:** This is normal for first deployment (no app to stop)
- Check deployment logs
- Ensure scripts have execute permissions

### Issue 3: Cannot Access Application on Port 3000
**Solution:**
- Check security group allows inbound traffic on port 3000
- Verify application is running: `pm2 status`
- Check if port is listening: `sudo netstat -tulpn | grep 3000`

### Issue 4: Build Fails - "npm test" Error
**Solution:** The test requires the application to not be listening
- If tests fail initially, you can remove `npm test` from buildspec.yml
- Or modify tests to not start the server

### Issue 5: Permission Denied on Script Execution
**Solution:**
```bash
# Make scripts executable (do this locally before pushing)
chmod +x scripts/*.sh
git add scripts/
git commit -m "Make scripts executable"
git push origin main
```

### Issue 6: GitHub Connection Fails
**Solution:**
- Ensure GitHub personal access token is valid and has correct scopes
- Try reconnecting GitHub in CodePipeline source settings
- Check if repository is public or token has private repo access

---

## 📊 Architecture Diagram

```
┌──────────┐        ┌───────────────┐        ┌─────────────┐
│          │        │               │        │             │
│  GitHub  │───────▶│ CodePipeline  │───────▶│  CodeBuild  │
│          │        │   (Source)    │        │   (Build)   │
└──────────┘        └───────────────┘        └─────────────┘
                            │                        │
                            │                        │
                            ▼                        ▼
                    ┌──────────────┐         ┌────────────┐
                    │              │         │            │
                    │  CodeDeploy  │◀────────│  S3 Bucket │
                    │   (Deploy)   │         │ (Artifacts)│
                    └──────────────┘         └────────────┘
                            │
                            │
                            ▼
                    ┌──────────────┐
                    │              │
                    │  EC2 Instance│
                    │  (Node.js +  │
                    │     PM2)     │
                    └──────────────┘
```

---

## 🎯 Project Structure

```
nodejs-cicd-pipeline/
├── server.js                 # Main application file
├── server.test.js            # Jest tests
├── package.json              # Dependencies
├── buildspec.yml             # CodeBuild configuration
├── appspec.yml               # CodeDeploy configuration
├── .gitignore                # Git ignore file
├── README.md                 # This file
└── scripts/                  # Deployment scripts
    ├── before_install.sh     # Pre-installation cleanup
    ├── after_install.sh      # Install dependencies
    ├── stop_application.sh   # Stop running app
    ├── start_application.sh  # Start app with PM2
    └── validate_service.sh   # Health check validation
```

---

## 📝 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Welcome message |
| GET | `/api/health` | Health check endpoint |
| GET | `/api/users` | Get all users |
| POST | `/api/users` | Create new user |

---

## 🔒 Security Best Practices

1. **IAM Roles**: Use least privilege principle
2. **Security Groups**: Restrict SSH access to your IP only
3. **Secrets**: Never commit sensitive data (use AWS Secrets Manager)
4. **HTTPS**: In production, use Application Load Balancer with SSL
5. **Environment Variables**: Use .env for configuration
6. **GitHub Token**: Rotate tokens regularly

---

## 💰 Cost Estimation

For the free tier:
- **EC2 t2.micro**: 750 hours/month free
- **CodeBuild**: 100 build minutes/month free
- **CodePipeline**: 1 active pipeline free
- **CodeDeploy**: Free for EC2
- **S3**: 5GB storage free

**Estimated monthly cost after free tier**: $10-15/month

---

## 🚀 Next Steps / Enhancements

1. **Add Database**: RDS PostgreSQL/MySQL
2. **Load Balancer**: Application Load Balancer for high availability
3. **Auto Scaling**: Auto Scaling Group for multiple EC2 instances
4. **Monitoring**: CloudWatch alarms and dashboards
5. **SSL/TLS**: HTTPS with ACM certificate
6. **Blue/Green Deployment**: Zero-downtime deployments
7. **Environment Variables**: AWS Parameter Store or Secrets Manager
8. **Unit Tests**: Expand test coverage
9. **Docker**: Containerize the application
10. **Infrastructure as Code**: Terraform or CloudFormation

---

## 📚 Additional Resources

- [AWS CodePipeline Documentation](https://docs.aws.amazon.com/codepipeline/)
- [AWS CodeBuild Documentation](https://docs.aws.amazon.com/codebuild/)
- [AWS CodeDeploy Documentation](https://docs.aws.amazon.com/codedeploy/)
- [Express.js Documentation](https://expressjs.com/)
- [PM2 Documentation](https://pm2.keymetrics.io/)

---

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

---

## 📄 License

This project is licensed under the ISC License.

---

## ✅ Completion Checklist

Use this checklist to track your implementation:

- [ ] Created GitHub repository
- [ ] Generated GitHub personal access token
- [ ] Launched EC2 instance
- [ ] Created and attached IAM role to EC2
- [ ] Installed CodeDeploy agent on EC2
- [ ] Created CodeDeploy application and deployment group
- [ ] Created CodeBuild project
- [ ] Created CodePipeline with Source, Build, and Deploy stages
- [ ] Pipeline executed successfully
- [ ] Application accessible on EC2
- [ ] Tested CI/CD by pushing code changes
- [ ] Verified automatic deployment

---

**🎉 Congratulations!** You've successfully set up a complete CI/CD pipeline for your Node.js application using AWS services!

For questions or issues, please refer to the troubleshooting section or check AWS CloudWatch logs.

