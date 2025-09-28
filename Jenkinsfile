// Define variables that will be used throughout the pipeline
def harborIp      = "192.168.206.52"
def harborProject = "library"
def imageName     = "react-cicd"

pipeline {
    agent any

    environment {
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        HARBOR_IMAGE = "${harborIp}/${harborProject}/${imageName}:${IMAGE_TAG}"
    }

    stages {
        stage('Checkout Code') {
		    steps {
		        // This command is powered by the Git plugin
		        checkout scm
		    }
		}
    }
}