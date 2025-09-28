// Define variables that will be used throughout the pipeline
def harborIp      = "192.168.206.52"
def harborProject = "library"
def imageName     = "react-cicd"

// Declare the customImage variable here, outside the pipeline block
def customImage

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

        stage('Build Image') {
            steps {
                script {
                    echo "Building Docker image: ${imageName}"
                    customImage = docker.build(imageName)
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