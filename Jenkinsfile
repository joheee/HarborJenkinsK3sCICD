// Define variables that will be used throughout the pipeline
def harborIp      = "192.168.206.52"
def harborProject = "library"
def imageName     = "react-cicd"
def deploymentFile = "k8s/deployment.yaml"

// Declare the customImage variable here, outside the pipeline block
def customImage

pipeline {
    agent any

    environment {
        // Generate the dynamic version tag, e.g., "1", "2", etc.
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        
        // Construct the full image name for Harbor
        HARBOR_IMAGE = "${harborIp}/${harborProject}/${imageName}:${IMAGE_TAG}"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build, Push, and Cleanup Image') {
            steps {
                script {
                    echo "Building Docker image as: ${HARBOR_IMAGE}"
                    customImage = docker.build(HARBOR_IMAGE, '--no-cache .')

                    echo "Logging into Harbor at ${harborIp}"
                    docker.withRegistry("http://${harborIp}", 'harbor-creds') {
                        echo "Pushing image to Harbor"
                        customImage.push()
                    }

                    echo "Cleaning up local Docker image"
                    sh "docker rmi ${HARBOR_IMAGE}"

                    echo "Pruning Docker build cache and unused data"
                    sh "docker system prune -f"
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

        
    }
}