// Define variables that will be used throughout the pipeline
def harborIp      = "192.168.206.52"
def harborProject = "library"
def imageName     = "react-cicd"

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

        stage('Build Image') {
            steps {
                script {
                    echo "Building Docker image: ${imageName}"
                    
                    def customImage = docker.build(imageName)

                    echo "Finish build docker image: ${imageName}"
                }
            }
        }

        stage('Push Image') {
            steps {
                script {
                    echo "Logging into Harbor at ${harborIp}"
                    docker.withRegistry("http://${harborIp}", 'harbor-creds') {
                        
                        echo "Tagging image as: ${HARBOR_IMAGE}"
                        customImage.tag(HARBOR_IMAGE)

                        echo "Pushing image to Harbor"
                        customImage.push()
                    }
                }
            }
        }
    }
}