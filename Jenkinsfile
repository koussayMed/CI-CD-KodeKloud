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

      
        
       stage('Set up Kubernetes Context') {
    steps {
        script {
            // Retrieve the kubeconfig content from Jenkins secret (Kubernetes credentials)
            withCredentials([string(credentialsId: "${KUBERNETES_CREDENTIALS}", variable: 'KUBECONFIG_CONTENT')]) {
                
                // Write the kubeconfig content securely into a temporary file
                writeFile file: '/tmp/kubeconfig', text: KUBECONFIG_CONTENT
                
                // Optional: Verify that the kubeconfig file is correctly written (check format, avoid printing secret)
                // You can skip this step after confirming everything works, it’s just for debugging
                // sh 'cat /tmp/kubeconfig'
                
                // Set the KUBECONFIG environment variable for kubectl to use the file
                sh 'export KUBECONFIG=/tmp/kubeconfig'

                // Verify the contexts in the kubeconfig file
                sh 'kubectl config get-contexts --kubeconfig /tmp/kubeconfig'
            }
        }
    }
}


        stage('Deploy to AKS') {
            steps {
                script {
                    echo "Deploying application to AKS..."
                    sh 'kubectl apply -f k8s/deployment.yaml'
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
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
