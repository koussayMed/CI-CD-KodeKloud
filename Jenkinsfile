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
                sh "pip install -r requirements.txt"
            }
        }
        stage('Test') {
            steps {
                sh '''
                python3 -m venv venv
                source venv/bin/activate
                pip install pytest
                pytest
                '''
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
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
        stage('Push Docker Image') {
            steps {
                sh 'docker push ${IMAGE_TAG}'
                echo "Docker image pushed successfully"
            }
        }
    }
}
