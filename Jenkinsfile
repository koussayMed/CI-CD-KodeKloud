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
    always {
        script {
            def jobName = env.JOB_NAME
            def buildNumber = env.BUILD_NUMBER
            def pipelineStatus = currentBuild.result ?: 'UNKNOWN'
            def bannerColor = pipelineStatus.toUpperCase() == 'SUCCESS' ? 'green' : 'red'

            def body = """<html>
                <body>
                    <div style="border: 4px solid ${bannerColor}; padding: 10px;">
                        <h2>${jobName} - Build ${buildNumber}</h2>
                        <div style="background-color: ${bannerColor}; padding: 10px;">
                            <h3 style="color: white;">Pipeline Status: ${pipelineStatus.toUpperCase()}</h3>
                        </div>
                        <p>Check the <a href="${BUILD_URL}">console output</a>.</p>
                        <p>Trivy scan results are attached.</p>
                    </div>
                </body>
            </html>"""

            emailext (
                subject: "${jobName} - Build ${buildNumber} - ${pipelineStatus.toUpperCase()}",
                body: body,
                to: 'koussayfattoum480@gmail.com',
                from: 'koussayfattoum480@gmail.com',
                mimeType: 'text/html',
                attachmentsPattern: 'trivy_report.json'
            )
            cleanWs()
        }
    }
}


}
