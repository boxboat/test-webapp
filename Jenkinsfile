@Library('jenkins-pipeline-library') _
pipeline('golang')

@Library('keysight-shared-library')_

pipeline {

    agent {
      docker {
        image 'golang:1.12-alpine'
      }
    }

    environment {
        branch = 'master'
    }

    stages {
        stage('checkout') {
            steps {
                //keysight_checkout()
                echo 'Pulling...'
            }
        }

        stage('build') {
            steps {
                //keysight_build()
                echo 'Building...'
            }
        }

        stage('scan') {
            steps {
                echo 'Scanning...'
            }
        }

        stage ('test') {
            steps {
                echo 'Testing...'
            }
        }

        stage ('package') {
            steps {
                sh "echo 'Packaging...' "
            }
        }

        stage ('secure') {
            steps {
                echo 'Securing...'
            }
        }

        stage ('publish') {
            steps {
                echo 'Publishing...'
            }
        }

        stage('deploy'){
            steps {
                //deploy(developmentServer, serverPort)
                echo 'Deploying...'
            }
        }

    }
    post {
        failure {
            //mail to: 'todd@boxboat.com', subject: 'Pipeline failed', body: "${env.BUILD_URL}"
            echo 'Failed...'
        }
    }
}
