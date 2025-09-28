// Define variables that will be used throughout the pipeline
def harborIp      = "192.168.206.52"
def harborProject = "library"
def imageName     = "react-cicd"

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

        stage('Build and Push Image') {
            steps {
                script {
                    echo "Building Docker image as: ${HARBOR_IMAGE}"
                    
                    // Build the image directly with the final tag
                    customImage = docker.build(HARBOR_IMAGE, '--no-cache .')

                    echo "Logging into Harbor at ${harborIp}"
                    docker.withRegistry("http://${harborIp}", 'harbor-creds') {
                        
                        echo "Pushing image to Harbor"
                        // No need to tag again, just push
                        customImage.push()
                    }
                }
            }
        }
        
        stage('Cleanup') {
            steps {
                script {
                    echo "Cleaning up local Docker image"
                    // Only need to remove the one final image
                    sh "docker rmi ${HARBOR_IMAGE}"
                }
            }
        }
    }
}