// Define variables
def harborIp      = "192.168.206.52"
def harborProject = "library"
def imageName     = "react-cicd"
def deploymentFile = "k8s/deployment.yaml"

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

                    // Use 'sed' to replace the placeholder in a temporary copy of the deployment file
                    sh "sed 's|react-cicd-image-placeholder|${HARBOR_IMAGE}|g' ${deploymentFile} > ${deploymentFile}.tmp"
                    
                    echo "Applying configuration to Kubernetes..."
                    withKubeConfig(credentialsId: 'k3s-config') {
                        // Apply the service - this will create it if it doesn't exist
                        sh "kubectl apply -f k8s/service.yaml"
                        
                        // Apply the deployment - this will create it on the first run,
                        // and update it with the new image on all subsequent runs.
                        sh "kubectl apply -f ${deploymentFile}.tmp"
                    }
                }
            }
        }
        
        stage('Cleanup') {
            steps {
                script {
                    echo "Cleaning up local Docker image"
                    sh "docker rmi ${HARBOR_IMAGE}"
                }
            }
        }
    }
}