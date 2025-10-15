pipeline {
  agent any

  environment {
    // 👇 Update this to your EC2 public DNS or IP
    EC2_HOST = 'ec2-xx-xx-xx-xx.compute.amazonaws.com'
  }

  triggers {
    // This works with GitHub webhook: https://<jenkins-url>/github-webhook/
    githubPush()
  }

  options {
    timestamps()
    ansiColor('xterm')
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }

  tools {
    // Configure under Manage Jenkins → Tools → NodeJS
    nodejs 'node20'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Install') {
      steps {
        sh 'npm ci'
      }
    }

    stage('Unit Tests') {
      steps {
        sh 'npm test'
      }
      post {
        always {
          junit testResults: 'reports/junit/junit.xml', allowEmptyResults: true
          publishHTML(target: [
            reportDir: 'coverage',
            reportFiles: 'index.html',
            reportName: 'Coverage HTML',
            keepAll: true,
            alwaysLinkToLastBuild: true
          ])
          archiveArtifacts artifacts: 'coverage/**,reports/junit/junit.xml', fingerprint: true
        }
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('MySonarQube') {
          sh '''
            # Ensure coverage lcov is present (usually from tests)
            [ -f coverage/lcov.info ] || echo "No lcov found, rerunning jest for lcov..."

            sonar-scanner               -Dsonar.projectKey=nodejs-jenkins-ec2-demo               -Dsonar.sources=src               -Dsonar.tests=test               -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info               -Dsonar.sourceEncoding=UTF-8
          '''
        }
      }
    }

    stage('Quality Gate') {
      steps {
        script {
          timeout(time: 10, unit: 'MINUTES') {
            def qg = waitForQualityGate()
            if (qg.status != 'OK') {
              error "Pipeline aborted due to Quality Gate failure: ${qg.status}"
            }
          }
        }
      }
    }

    stage('Package') {
      steps {
        sh '''
          tar -czf artifact.tgz             --exclude=node_modules             --exclude=.git             --exclude=coverage             .
        '''
        archiveArtifacts artifacts: 'artifact.tgz', fingerprint: true
      }
    }

    stage('Deploy to EC2') {
      when { branch 'main' }
      steps {
        sshagent(credentials: ['ec2-ssh']) {
          sh '''
            chmod +x scripts/*.sh || true
            ./scripts/deploy.sh ${EC2_HOST}
            ./scripts/restart.sh ${EC2_HOST}
          '''
        }
      }
    }
  }

  post {
    always {
      echo "Build finished. Find 'Coverage HTML' link on the build page."
    }
  }
}
