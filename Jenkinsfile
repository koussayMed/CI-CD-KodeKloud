pipeline {
    agent any
    
    environment {
        IMAGE_NAME = 'koussayfattoum480432/jenkins-flask-app'
        IMAGE_TAG = "${IMAGE_NAME}:${env.BUILD_NUMBER}"
        LATEST_TAG = "${IMAGE_NAME}:latest"
        KUBERNETES_CREDENTIALS = 'k8s-kubeconfig'  // The ID of the Secret Text credential for kubeconfig
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    git url: 'https://github.com/koussayMed/CI-CD-KodeKloud.git', branch: 'main'
                }
            }
        }

        stage("SonarQube Code Analysis") {
            steps {
                script {
                    // Use the SonarQube Scanner tool configured in Jenkins
                    def sonarScanner = tool name: 'SonarQubeScanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
                    
                    // Set the SonarQube scanner command with the path to the scanner
                    def sonarScannerCommand = "${sonarScanner}/bin/sonar-scanner -Dsonar.projectName=cicd -Dsonar.sources=. -Dsonar.projectKey=cicd -Dsonar.host.url=http://192.168.133.134:9000 -Dsonar.login=squ_708e10578a9fd4b64204978a4ff9a745d6426090"
                    
                    // Debug: print the sonarScannerCommand to ensure it's correct
                    echo "Running SonarQube Scanner with the following command: ${sonarScannerCommand}"
                    
                    // Execute the SonarQube scanner command
                    sh script: sonarScannerCommand, returnStatus: true
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

        // Kubernetes Deployment Stage
        stage('Set up Kubernetes Context') {
            steps {
                script {
                    // Retrieve the kubeconfig stored as a secret text
                    withCredentials([string(credentialsId: "${KUBERNETES_CREDENTIALS}", variable: 'KUBECONFIG_CONTENT')]) {
                        // Write the kubeconfig content to a temporary file
                        writeFile file: '/tmp/kubeconfig', text: "${KUBECONFIG_CONTENT}"

                        // Set the KUBECONFIG environment variable to point to the temporary kubeconfig file
                        sh 'export KUBECONFIG=/tmp/kubeconfig'

                        // Verify the Kubernetes cluster context
                        sh 'kubectl config get-contexts --kubeconfig /tmp/kubeconfig'
                    }
                }
            }
        }

        stage('Deploy to AKS') {
            steps {
                script {
                    // Apply Kubernetes deployment YAML file to AKS cluster
                    echo "Deploying application to AKS..."
                    sh 'kubectl apply -f k8s/deployment.yaml --kubeconfig /tmp/kubeconfig'

                    // Optionally, you can check the deployment status
                    sh 'kubectl rollout status deployment/my-app --kubeconfig /tmp/kubeconfig'
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    // Verify the deployment and check the pods running in the AKS cluster
                    echo "Verifying deployment in AKS..."
                    sh 'kubectl get pods --kubeconfig /tmp/kubeconfig'
                    sh 'kubectl get services --kubeconfig /tmp/kubeconfig'
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
