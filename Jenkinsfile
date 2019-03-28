#!/usr/bin/env groovy

// @Library('keysight-shared-library')_
// pipelineGolang()

// The above line is used to trigger correct syntax highlighting.

pipeline {
    // Lets Jenkins use Docker for us later.
    agent any

    // environment{
        
    // }

    // If anything fails, the whole Pipeline stops.
    stages {
        stage('Build') {   
            // Use golang.
            agent { 
                docker { 
                    image 'golang'
                    args '-u root --privileged' // needed for writing golang .cache
                    // failed to initialize build cache at /.cache/go-build: mkdir /.cache: permission denied
                    // registryUrl 'https://registry.az1'
                    // registryCredentialsId 'credentials-id'
                } 
            }

            steps {                                         
                // Create our project directory.
                sh 'cd ${GOPATH}/src'
                sh 'mkdir -p ${GOPATH}/src/MY_PROJECT_DIRECTORY'

                // Copy all files in our Jenkins workspace to our project directory.                
                sh 'cp -r ${WORKSPACE}/* ${GOPATH}/src/MY_PROJECT_DIRECTORY'

                // // Copy all files in our "vendor" folder to our "src" folder.
                // sh 'cp -r ${WORKSPACE}/vendor/* ${GOPATH}/src'

                // Build the app.
                sh 'go build'               
            }            
        }

        stage('Test') {
            // Use golang.
            agent { 
                docker { 
                    image 'golang'
                    args '-u root --privileged'
                } 
            }

            steps {                 
                // Create our project directory.
                sh 'cd ${GOPATH}/src'
                sh 'mkdir -p ${GOPATH}/src/MY_PROJECT_DIRECTORY'

                // Copy all files in our Jenkins workspace to our project directory.                
                sh 'cp -r ${WORKSPACE}/* ${GOPATH}/src/MY_PROJECT_DIRECTORY'

                // // Copy all files in our "vendor" folder to our "src" folder.
                // sh 'cp -r ${WORKSPACE}/vendor/* ${GOPATH}/src'

                // Remove cached test results.
                sh 'go clean -cache'

                // Run Unit Tests.
                sh 'go test ./... -v -short'            
            }
        }      

        stage('Docker') {         
            environment {
                // Extract the username and password of our credentials into "DOCKER_CREDENTIALS_USR" and "DOCKER_CREDENTIALS_PSW".
                // (NOTE 1: DOCKER_CREDENTIALS will be set to "your_username:your_password".)
                // The new variables will always be YOUR_VARIABLE_NAME + _USR and _PSW.
                // (NOTE 2: You can't print credentials in the pipeline for security reasons.)
                DOCKER_CREDENTIALS = credentials('docker-registry-credentials')
            }

            steps {                           
                // Use a scripted pipeline.
                script {
                    node {
                        def app

                        stage('Clone repository') {
                            checkout scm
                        }

                        stage('Build image') {
                            docker.withRegistry('https://registry.hub.docker.com', 'docker-registry-credentials') {                                
                                def customImage = docker.build( "toddbox/test-webapp:1.${env.BUILD_ID}" )
                                customImage.push()                          
                                //app = docker.build("${env.DOCKER_CREDENTIALS_USR}/my-project-img")
                                
                                // Push image and tag it with our build number for versioning purposes.
                                //app.push( "toddbox/test-webapp:${env.BUILD_ID}" )                       

                                // Push the same image and tag it as the latest version (appears at the top of our version list).
                                //app.push("latest")
                            }

                        }

                        // stage('Push image') {  
                        //     // Use the Credential ID of the Docker Hub Credentials we added to Jenkins.
                        //     docker.withRegistry('https://hub.docker.com', 'docker-registry-credentials') {                                
                        //         // Push image and tag it with our build number for versioning purposes.
                        //         app.push( "toddbox/test-webapp:${env.BUILD_ID}" )                       

                        //         // Push the same image and tag it as the latest version (appears at the top of our version list).
                        //         //app.push("latest")
                        //     }
                        // }              
                    }                 
                }
            }
        }
    }

    post {
        always {
            // Clean up our workspace.
            deleteDir()
        }
        // success {
        //     slackSend channel:'#ops-room',
        //     color: 'good',
        //     message: 'Completed successfully.'
        // }
        // failure {
        //     mail to: 'todd@boxboat.com',
        //     subject: 'Failed Pipeline',
        //     body: "Something is wrong"
        // }
    }
} 
