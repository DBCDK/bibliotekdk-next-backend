#! groovy
@Library('frontend-dscrum')

// general vars
def DOCKER_REPO = "docker-dscrum.dbc.dk"
def PRODUCT = 'bibdk-backend'
def BRANCH
BRANCH = BRANCH_NAME.replaceAll('feature/', '')
BRANCH = BRANCH.replaceAll('_', '-')

// artifactory buildname
def BUILDNAME = 'Bibdk-backend :: ' + BRANCH

pipeline {
    agent {
        node { label 'devel10-head' }
    }
    options {
        buildDiscarder(logRotator(artifactDaysToKeepStr: "", artifactNumToKeepStr: "", daysToKeepStr: "", numToKeepStr: "5"))
        timestamps()
        gitLabConnection('gitlab.dbc.dk')
        // Limit concurrent builds to one pr. branch.
        disableConcurrentBuilds()
    }
    triggers {
        gitlab(
                triggerOnPush: true,
                triggerOnMergeRequest: true,
                branchFilterType: 'All',
                addVoteOnMergeRequest: true
        )
    }
    stages {
        // Build the Drupal website image.
        stage('Docker www') {
            steps {
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

                    sh """
                    docker rmi ${DOCKER_REPO}/${PRODUCT}-www-${BRANCH}:${currentBuild.number}
                    docker rmi ${DOCKER_REPO}/${PRODUCT}-db-${BRANCH}:${currentBuild.number}
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                  sh """ echo FISK """

                }
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
