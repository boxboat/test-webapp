#!/usr/bin/env groovy

// The above line is used to trigger correct syntax highlighting.

// @Library('keysight-shared-library')_
// pipelineGolang()


// # git, svn, cvs
// checkout()

// # PMD, CheckStyle, FindBugs
// scan()

// # java, C#, golang
// build()

// # sonarqube
// test()

// # docker, helm, pulp
// package()

// # coverity, checkmarx, fortify, etc.
// secure()

// # artifactory, git, pulp
// publish()
// kosiHub (keysight open source inside)
// doxygen

// # jenkins, ansible
// deploy()

def slack_response = ''
def slack_channel = ''

pipeline {
    // Lets Jenkins use Docker for us later.
    parameters {
        
        string(name: 'slack_', defaultValue: '')
    }
    
    agent any

    // environment{
        
    // }

    // If anything fails, the whole Pipeline stops.
    stages {

        stage('Setup') {   
            // Use sonar-scanner.
            agent any
            steps {
                script{
                    slack_response = slackSend( color: 'good', message: "Build: ${env.BUILD_ID}: Starting" )
                }
                // slackSend color: 'good', message: "Build: ${env.BUILD_ID}: Starting"
            }
        }

        stage('Lint') {   
            // Use sonar-scanner.
            agent { 
                docker { 
                    image 'boxboat/sonar-scanner'
                    args '-it --user 0:0 -v ${WORKSPACE}:/root/src'
                }
            }
            steps {
                script{
                    //slack_response = slackSend( color: 'good', message: "Build: ${env.BUILD_ID}: Starting" )
                    slackSend( channel: slack_response.threadId, color: 'good', message: "Build: ${env.BUILD_ID}: Linting" )
                }
                //slackSend( channel: slack_response.threadId, color: 'good', message: "Build: ${env.BUILD_ID}: Linting" )
                //slackSend color: 'good', message: 'Message from Jenkins Pipeline'
                sh 'sonar-scanner -Dsonar.projectBaseDir=.'
            }
        }

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

        stage('Package') {         
            environment {
                // Extract the username and password of our credentials into "DOCKER_CREDENTIALS_USR" and "DOCKER_CREDENTIALS_PSW".
                // (NOTE 1: DOCKER_CREDENTIALS will be set to "your_username:your_password".)
                // The new variables will always be YOUR_VARIABLE_NAME + _USR and _PSW.
                DOCKER_CREDENTIALS = credentials('docker-registry-credentials')
            }

            steps {                           
                // Use a scripted pipeline.
                script {
                    node {
                        def app

                        // stage('Clone repository') {
                        //     checkout scm
                        // }

                        // stage('Build image') {
                        //     def customImage = docker.build( "boxboat/test-webapp" )
                        //     customImage.push( "1.${env.BUILD_ID}" )
                        //     customImage.push( "latest" )
                        // }

                        stage('Push image') {  
                            docker.withRegistry('https://registry.hub.docker.com', 'docker-registry-credentials') 
                            {
                                def customImage = docker.build( "boxboat/test-webapp" )
                                customImage.push( "1.${env.BUILD_ID}" )
                                customImage.push( "latest" )
                            }
                        }
                        
                        stage('Container Scan') {
                            // onDisallowed: 'ignore' || 'fail'
                            aquaMicroscanner imageName: 'boxboat/test-webapp', notCompliesCmd: 'exit 1', onDisallowed: 'fail'
                            //aquaMicroscanner imageName: 'alpine:latest', notCompliesCmd: 'exit 1', onDisallowed: 'fail'
                            //aquaMicroscanner imageName: 'lizrice/struts:vulnerable', notCompliesCmd: 'exit 1', onDisallowed: 'ignore'
                        }
                    }
                }
            }
        }

        stage('Publish') {
            // Use golang.
            agent any

            steps {                 
                // Create our project directory.
                sh 'build/publish.sh'          
            }
        }

        stage('Deploy') {
            // Use golang.
            agent any

            steps {                 
                // Create our project directory.
                sh 'build/deploy.sh'
                sh 'build/deploy.sh'
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
