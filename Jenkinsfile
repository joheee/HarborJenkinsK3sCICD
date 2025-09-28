// VARIABLES
def harborIp       = "192.168.206.52"
def harborProject  = "library"
def imageName      = "react-cicd"
def deploymentFile = "k8s/deployment.yaml"
def tempDeploymentFile = "${deploymentFile}.tmp"

pipeline {
    agent any

    environment {
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        HARBOR_IMAGE = "${harborIp}/${harborProject}/${imageName}:${IMAGE_TAG}"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build and Push Image') {
            steps {
                script {
                    def customImage = docker.build(HARBOR_IMAGE)
                    docker.withRegistry("http://${harborIp}", 'harbor-creds') {
                        customImage.push()
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo "Updating deployment manifest with new image: ${HARBOR_IMAGE}"
                    sh "sed 's|react-cicd-image-placeholder|${HARBOR_IMAGE}|g' ${deploymentFile} > ${tempDeploymentFile}"
                    
                    withKubeConfig(credentialsId: 'k3s-config') {
                        echo "Applying configuration to Kubernetes..."
                        sh "kubectl apply -f k8s/service.yaml"
                        sh "kubectl apply -f ${tempDeploymentFile}"
                    }
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo "--- Post-build cleanup ---"
                
                echo "Cleaning up local Docker image..."
                sh "docker rmi -f ${HARBOR_IMAGE} || true"

                echo "Cleaning up temporary deployment file..."
                sh "rm -f ${tempDeploymentFile} || true"

                echo "Pruning Docker build cache..."
                sh "docker system prune -f || true"
            }
        }
    }
}