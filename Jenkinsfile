#! groovy
@Library('pu-deploy')
@Library('frontend-dscrum')

def fisk = "JE"

pipeline {
    options {
        buildDiscarder(logRotator(artifactDaysToKeepStr: "", artifactNumToKeepStr: "", daysToKeepStr: "", numToKeepStr: "5"))
        timestamps()
        gitLabConnection('gitlab.dbc.dk')
        // Limit concurrent builds to one pr. branch.
        disableConcurrentBuilds()
    }
    environment {
        // general vars
        DOCKER_REPO = "docker-dscrum.dbc.dk"
        // product name
        PRODUCT = 'bibdk-backend'
        // branch name to use in build
        BRANCH = BRANCH_NAME.replaceAll('feature/', '').replaceAll('_', '-')
        // artifactory buildname
        BUILDNAME = "Bibdk-backend :: ${BRANCH}"
    }
    triggers {
        gitlab(
                triggerOnPush: true,
                triggerOnMergeRequest: true,
                branchFilterType: 'All',
                addVoteOnMergeRequest: true
        )
    }
    agent {
        node { label 'devel10-head' }
    }
    stages {
        // Build the Drupal website image.
        stage('Docker www') {
            steps {
                currentBuild.description = "Build ${BUILDNAME}:${currentBuild.number}"
                dir('docker/www') {
                    script {
                        docker.build("${DOCKER_REPO}/${PRODUCT}-www-${BRANCH}:${currentBuild.number}",
                                "--build-arg BRANCH=${BRANCH_NAME} .")
                    }
                }
            }
        }
        stage('Docker db') {
            steps {
                dir('docker/db') {
                    script {
                        docker.build("${DOCKER_REPO}/${PRODUCT}-db-${BRANCH}:${currentBuild.number}",
                                "--no-cache .")
                    }
                }
            }
        }

        /*
        stage('Docker: push & cleanup') {
            steps {
                script {
                    def artyServer = Artifactory.server 'arty'
                    def artyDocker = Artifactory.docker server: artyServer, host: env.DOCKER_HOST

                    def buildInfo_www = Artifactory.newBuildInfo()
                    buildInfo_www.name = BUILDNAME
                    buildInfo_www = artyDocker.push("${DOCKER_REPO}/${PRODUCT}-www-${BRANCH}:${currentBuild.number}", 'docker-dscrum', buildInfo_www)
                    buildInfo_www.env.capture = true
                    buildInfo_www.env.collect()

                    def buildInfo_db = Artifactory.newBuildInfo()
                    buildInfo_db.name = BUILDNAME
                    buildInfo_db = artyDocker.push("${DOCKER_REPO}/${PRODUCT}-db-${BRANCH}:${currentBuild.number}", 'docker-dscrum', buildInfo_db)

                    buildInfo_www.append buildInfo_db
                    artyServer.publishBuildInfo buildInfo_www


                }
            }
        }

         */
        stage('docker cleanup'){
            steps{
                script{
                    sh """
                    docker rmi ${DOCKER_REPO}/${PRODUCT}-www-${BRANCH}:${currentBuild.number}
                    docker rmi ${DOCKER_REPO}/${PRODUCT}-db-${BRANCH}:${currentBuild.number}
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                sh """ echo FISK """
                sh """ echo $BRANCH_NAME """
            }
        }
    }
    post {
        always {
            sh """
      echo WORKSPACE: ${env.WORKSPACE}
      """
            cleanWs()
            dir("${env.WORKSPACE}@2") {
                deleteDir()
            }
            dir("${env.WORKSPACE}@2@tmp") {
                deleteDir()
            }
            dir("${env.WORKSPACE}@tmp") {
                deleteDir()
            }
        }
    }
}
