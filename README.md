# nodejs-jenkins-ec2-demo

End-to-end demo: **GitHub push → GitHub Webhook → Jenkins Pipeline → Jest Unit Tests → HTML Coverage → SonarQube → Deploy to EC2 (PM2)**

## Repo Contents
- `Jenkinsfile` – CI/CD pipeline
- `sonar-project.properties` – SonarQube project config
- `package.json` – Jest + jest-junit + coverage
- `src/index.js` – Simple HTTP server with `/health`
- `test/sample.test.js` – Basic tests
- `scripts/deploy.sh` / `scripts/restart.sh` – rsync deploy + PM2 restart

## Prereqs (Jenkins)
- Plugins: Pipeline, GitHub, Git, NodeJS, HTML Publisher, JUnit, SonarQube Scanner, SSH Agent
- Tools: NodeJS tool named **node20**; SonarQube Scanner if you prefer (or use server config)
- Manage Jenkins → System → SonarQube servers: add server named **MySonarQube**, check “Environment variables”
- Credentials:
  - SSH key for EC2 with ID **ec2-ssh** (SSH Username with private key)

## GitHub Webhook
- In Jenkins job: check **GitHub hook trigger for GITScm polling**
- In GitHub repo: Settings → Webhooks → Add
  - Payload URL: `https://<jenkins-url>/github-webhook/`
  - Content-type: `application/json`
  - Events: **Just the push event**

## EC2 Prep (Ubuntu)
```bash
# Create app user and dir
sudo useradd -m -s /bin/bash nodeapp || true
sudo mkdir -p /var/www/nodejs-jenkins-ec2-demo
sudo chown -R nodeapp:nodeapp /var/www/nodejs-jenkins-ec2-demo

# Node & PM2
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get update && sudo apt-get install -y nodejs build-essential rsync
sudo npm i -g pm2
```

## Configure Jenkinsfile
- Update `EC2_HOST` in `Jenkinsfile`
- Ensure your Jenkins has:
  - NodeJS tool named `node20`
  - SonarQube server named `MySonarQube`
  - Credentials ID `ec2-ssh`
- The pipeline stages:
  1. Install deps
  2. Run tests (JUnit + HTML coverage)
  3. SonarQube analysis + wait for Quality Gate
  4. Package artifact
  5. Deploy to EC2 (main branch only)

## Run Locally (optional)
```bash
npm ci
npm test
npm start
# open http://localhost:3000
```

## Notes
- HTML coverage report is published in Jenkins as **Coverage HTML**
- JUnit test results shown in Jenkins Tests tab
- Quality Gate enforced: build fails if gate fails
- PM2 keeps the Node.js app running on EC2
