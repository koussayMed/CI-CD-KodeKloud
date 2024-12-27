pipeline {
    agent any
    environment {
        IMAGE_NAME = 'koussayfattoum480432/jenkins-flask-app'
        IMAGE_TAG = "${IMAGE_NAME}:${env.BUILD_NUMBER}"
    }
    stages {

        stage('Checkout') {
            steps {
                git url: 'https://github.com/koussayMed/CI-CD-KodeKloud.git', branch: 'main'
                sh "ls -ltr"
            }
        }

        stage('Setup') {
            steps {
                // Install dependencies
                sh "pip install -r requirements.txt"
            }
        }

        stage('Test') {
            steps {
                sh '''
                # Create and activate virtual environment
                python3 -m venv venv
                . venv/bin/activate

                # Install dependencies
                pip install -r requirements.txt

                # Run the tests
                pytest
                '''
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh 'echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin'
                }
                echo 'Login successfully'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${IMAGE_TAG} .'
                echo "Docker image built successfully"
                sh "docker images"
            }
        }

        stage('Trivy Scan') {
            steps {
                script {
                    def scanResult = sh(script: "trivy image --severity CRITICAL --exit-code 1 --format json --output trivy_report.json ${IMAGE_TAG}", returnStatus: true)
                    if (scanResult != 0) {
                        error("Trivy scan found critical vulnerabilities. Check 'trivy_report.json' for details.")
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh 'docker push ${IMAGE_TAG}'
                echo "Docker image pushed successfully"
            }
        }
    }

    post {
        always {
            echo "Cleaning up workspace..."
            sh 'docker system prune -f'
        }
        success {
            emailext(
                subject: "CI/CD Pipeline Success: ${IMAGE_NAME}:${env.BUILD_NUMBER}",
                body: """
                The CI/CD pipeline completed successfully for image: ${IMAGE_TAG}.

                Trivy scan results are attached. Please review them for any non-critical issues.
                """,
                recipientProviders: [[$class: 'DevelopersRecipientProvider']],
                attachmentsPattern: 'trivy_report.json'
            )
        }
        failure {
            emailext(
                subject: "CI/CD Pipeline Failure: ${IMAGE_NAME}:${env.BUILD_NUMBER}",
                body: """
                The CI/CD pipeline failed during execution. 

                Please check the logs for further details.
                """,
                recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
        }
    }
}
