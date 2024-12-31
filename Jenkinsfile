pipeline {
    agent any
    
    environment {
        IMAGE_NAME = 'koussayfattoum480432/jenkins-flask-app'
        IMAGE_TAG = "${IMAGE_NAME}:${env.BUILD_NUMBER}"
        LATEST_TAG = "${IMAGE_NAME}:latest"
        registryName='kodekloud'
        registryCredential = 'ACR'
        registryUrl='kodekloud.azurecr.io'  // The ID of the Secret Text credential for kubeconfig
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    git url: 'https://github.com/koussayMed/CI-CD-KodeKloud.git', branch: 'main'
                }
            }
        }

      
        
       stage('Upload Image to ACR') {
         steps{   
             script {
                docker.withRegistry( "http://${registryUrl}", registryCredential ) {
                dockerImage.push()
                }
            }
          }
        }
        
        stage ('K8S Deploy') {
          steps {
            script {
                withKubeConfig([credentialsId: 'K8S', serverUrl: '']) {
                sh ('kubectl apply -f  jenkins-aks-deploy-from-acr.yaml')
                }
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
