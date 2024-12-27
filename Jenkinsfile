pipeline {
    agent any
    environment {
        IMAGE_NAME = 'koussayfattoum480432/jenkins-flask-app'
        IMAGE_TAG = "${IMAGE_NAME}:${env.BUILD_NUMBER}"
    }
    options {
        retry(2) // Retry pipeline up to 2 times on failure
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
                sh "pip install --upgrade pip"
                sh "pip install -r requirements.txt"
            }
        }

        stage('Test') {
            steps {
                sh '''
                python3 -m venv venv
                . venv/bin/activate
                pip install -r requirements.txt
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
                    def scanStatus = sh(script: "trivy image --scanners vuln --timeout 5m --format json --output trivy_report.json ${IMAGE_TAG}", returnStatus: true)
                    if (scanStatus != 0) {
                        echo "Trivy scan found vulnerabilities. Review 'trivy_report.json'."
                        error "Trivy scan failed with vulnerabilities."
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    try {
                        sh 'docker push ${IMAGE_TAG}'
                        echo "Docker image pushed successfully"
                    } catch (Exception e) {
                        echo "Failed to push Docker image: ${e.getMessage()}"
                    }
                }
            }
        }
    }

    post {
    success {
        emailext(
            subject: "Pipeline Success: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: """
            Hi, I'm Koussay.

            The pipeline completed successfully.

            Job: ${env.JOB_NAME}
            Build Number: ${env.BUILD_NUMBER}
            Build URL: ${env.BUILD_URL}

            Trivy scan results are attached.
            """,
            from: 'koussayfattoum480@gmail.com',
            to: 'koussayfattoum480@gmail.com',
            attachmentsPattern: 'trivy_report.json'
        )
    }
    failure {
        emailext(
            subject: "Pipeline Failure: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: """
            The pipeline failed.

            Job: ${env.JOB_NAME}
            Build Number: ${env.BUILD_NUMBER}
            Build URL: ${env.BUILD_URL}

            Please review the logs and Trivy scan results.
            """,
            from: 'koussayfattoum480@gmail.com',
            to: 'koussayfattoum480@gmail.com',
            attachmentsPattern: 'trivy_report.json'
        )
    }
}


}
