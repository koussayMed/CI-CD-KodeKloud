pipeline {
    agent any
    environment {
        IMAGE_NAME = 'koussayfattoum480432/jenkins-flask-app'
        IMAGE_TAG = "${IMAGE_NAME}:${env.BUILD_NUMBER}"
        LATEST_TAG = "${IMAGE_NAME}:latest"
        SONAR_SCANNER_HOME = tool name: 'sonar-scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
           
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "Checking out code from branch: ${params.BRANCH}"
                    git url: 'https://github.com/koussayMed/CI-CD-KodeKloud.git', branch: params.BRANCH
                }
            }
        }

        stage('SonarQube Analysis') {
            steps{
                def scannerHome = tool 'sonar-scanner';
                withSonarQubeEnv() {
                sh "${scannerHome}/bin/sonar-scanner"
                }

            }
            
        }

        stage('Setup') {
            steps {
                sh """
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt
                """
            }
        }

        stage('Test') {
            steps {
                script {
                    echo "Running tests..."
                    sh """
                        . venv/bin/activate
                        pytest --junitxml=test-results.xml
                    """
                }
            }
            post {
                always {
                    junit 'test-results.xml' // Publish test results
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh 'echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin'
                }
                echo 'Docker login successful'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image with tags: ${IMAGE_TAG} and ${LATEST_TAG}"
                    sh """
                        docker build -t ${IMAGE_TAG} -t ${LATEST_TAG} .
                        docker images
                    """
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                script {
                    echo "Running Trivy security scan on ${IMAGE_TAG}"
                    def scanStatus = sh(script: "trivy image --scanners vuln --timeout 5m --severity HIGH,CRITICAL --format json --output trivy_report.json ${IMAGE_TAG}", returnStatus: true)
                    if (scanStatus != 0) {
                        echo "Trivy scan found vulnerabilities. See 'trivy_report.json'."
                        archiveArtifacts artifacts: 'trivy_report.json', allowEmptyArchive: true
                        error "Trivy scan failed with vulnerabilities."
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "Pushing Docker image to Docker Hub: ${IMAGE_TAG} and ${LATEST_TAG}"
                    sh """
                        docker push ${IMAGE_TAG}
                        docker push ${LATEST_TAG}
                    """
                }
            }
        }

        stage('Cleanup Docker Images') {
            steps {
                script {
                    echo "Cleaning up old Docker images..."
                    sh """
                        docker rmi -f ${IMAGE_TAG} || true
                        docker image prune -f
                    """
                }
            }
        }
    }

    post {
        always {
            cleanWs() // Cleanup workspace after the pipeline
        }
        success {
            script {
                echo "Pipeline completed successfully!"
            }
        }
        failure {
            script {
                echo "Pipeline failed. Please review the logs."
            }
        }
    }
}
