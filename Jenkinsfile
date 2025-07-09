pipeline {
  agent any
  tools {
    maven 'Maven 3.8.8'       
    jdk 'Temurin JDK 17'
  }
 
  environment {
    SONARQUBE_SERVER = 'SonarQube' 
    IMAGE_NAME = 'cicd-challenge'
    IMAGE_TAG = 'latest'
    DOCKERFILE_BUILD_PATH = 'dockerbuild/Dockerfile'
    DOCKERHUB_USER = 'oeuvre13'
    TF_DIR = 'terraform'
    GOOGLE_APPLICATION_CREDENTIALS = 'gcp-key.json'
    GOOGLE_PROJECT = 'rakamin-ttc-odp-it-4'
    TELEGRAM_BOT_TOKEN = '8029797501:AAHvAp4KV1KUabDAFN-Kalc58MDKm1sgQyc'
    TELEGRAM_CHAT_ID = '2052628431'
  }
 
  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/oeuvre13/cicd-challenge', branch: 'master'
      }
    }
 
    stage('Unit Test & Coverage') {
      steps {
        sh 'mvn package'
      }
      post {
        always {
          junit 'target/surefire-reports/*.xml'
        }
      }
    }
 
    stage('Static Code Analysis (SAST) via Sonar') {
      steps {
        sh """
            mvn clean compile sonar:sonar \
              -Dsonar.projectKey=cicd-challenge \
              -Dsonar.projectName='cicd-challenge' \
              -Dsonar.host.url=http://sonarqube:9000 \
              -Dsonar.token=sqp_4ee12ac68f34739ce6ef24d45e5e409f34ad7f53
        """
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -f ${DOCKERFILE_BUILD_PATH} -t ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} .'
      }
    }

    stage('Push to Docker Hub') {
        // when {
        //     expression { return env.DOCKERHUB_USER && env.DOCKERHUB_TOKEN }
        // }
        steps {
            withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                sh """
                echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }


        // script {
        //     docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-creds') {
        //             def image = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
        //             image.push()
        //         }
        //     }
        // }
    }

    stage('Setup GCP Auth') {
    steps {
    withCredentials([file(credentialsId: 'gcp-sa-key', variable: 'GCP_KEY_FILE')]) {
    sh 'cp $GCP_KEY_FILE terraform/gcp-key.json'
    sh 'cat gcp-key.json'
    }
    }
    }

    stage('Terraform Init') {
    steps {
    dir("${TF_DIR}") {
    sh 'terraform init -input=false'
    }
    }
    }

    stage('Terraform Plan') {
    steps {
    dir("${TF_DIR}") {
    sh 'terraform plan -out=tfplan'
    }
    }
    }

    stage('Terraform Apply') {
    steps {
    dir("${TF_DIR}") {
    sh 'terraform apply -input=false -auto-approve tfplan'
    }
    }
    }
    
      stage('Send Telegram Notification'){
          steps {
              script {
                  if (params.ENABLE_NOTIFICATIONS) {
                      def startMessage = """
                          🚀 <b>CI/CD Pipeline Started</b>
                          ━━━━━━━━━━━━━━━━━━━━━━━
                          📋 <b>Job:</b> ${env.JOB_NAME}
                      🔢 <b>Build:</b> #${env.BUILD_NUMBER}
                      🌿 <b>Branch:</b> ${env.BRANCH_NAME ?: 'main'}
                      🏷️ <b>Tag:</b> ${env.FINAL_TAG}
                      👤 <b>Triggered by:</b> ${env.BUILD_USER ?: 'System'}
                      ⏰ <b>Started at:</b> ${new Date().format('yyyy-MM-dd HH:mm:ss')}
                      🔗 <b>Console:</b> ${env.BUILD_URL}console
                          """
                          sendTelegramMessage(startMessage)
                  }
              }
          }
      }
  }
 
  post {
    success {
      echo "Pipeline berhasil 🚀"
    }
    failure {
      echo "Pipeline gagal 💥"
    }
  }
}

def sendTelegramMessage(String message) {
    if (!params.ENABLE_NOTIFICATIONS) {
        return
    }
    
    try {
        echo "📱 Sending Telegram notification:"
        echo "Message: ${message}"
        echo "✅ Telegram notification sent successfully (simulated)"
    } catch (Exception e) {
        echo "❌ Telegram notification error: ${e.getMessage()}"
    }

    try {
        def encodedMessage = message.replaceAll('"', '\\\\"')
        def maxRetries = 3
        def retryCount = 0
        def success = false
    
        while (retryCount < maxRetries && !success) {
            try {
                def response = sh(
                    script: """
                        curl -s -X POST https://api.telegram.org/bot\${TELEGRAM_BOT_TOKEN}/sendMessage \
                            -d chat_id=\${TELEGRAM_CHAT_ID} \
                            -d text="${encodedMessage}" \
                            -d parse_mode=HTML \
                            -w "HTTP_CODE:%{http_code}"
                    """,
                    returnStdout: true
                ).trim()
                
                if (response.contains('HTTP_CODE:200')) {
                    echo "✅ Telegram notification sent successfully"
                    success = true
                } else {
                    throw new Exception("HTTP error: ${response}")
                }
            } catch (Exception e) {
                retryCount++
                echo "⚠️ Telegram notification attempt ${retryCount} failed: ${e.getMessage()}"
                if (retryCount < maxRetries) {
                    sleep(time: 5, unit: 'SECONDS')
                }
            }
        }
        
        if (!success) {
            echo "❌ Failed to send Telegram notification after ${maxRetries} attempts"
        }
    } catch (Exception e) {
        echo "❌ Telegram notification error: ${e.getMessage()}"
    }
}
