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
                // Install dependencies from requirements.txt (which should include Flask)
                sh "pip install -r requirements.txt"
            }
        }

        stage('Test') {
            steps {
                sh '''
                # Create and activate virtual environment
                python3 -m venv venv
                . venv/bin/activate

                # Install necessary Python dependencies (including Flask)
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
                sh "trivy image --format json --output trivy_report.json ${IMAGE_TAG}"
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
        success {
            // Send email notification on successful build
            emailext(
                subject: "CI/CD Pipeline - Build Successful for ${IMAGE_NAME}:${env.BUILD_NUMBER}",
                body: "The build for image ${IMAGE_NAME}:${env.BUILD_NUMBER} has completed successfully. \n Trivy scan report attached.",
                recipientProviders: [[$class: 'DevelopersRecipientProvider']],
                attachmentsPattern: 'trivy_report.json'
            )
        }
    }
}