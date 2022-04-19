#! groovy
@Library('pu-deploy')
@Library('frontend-dscrum')

def wwwImage
def dbImage

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
        DOCKER_REPO = "docker-frontend.artifacts.dbccloud.dk"
        // product name
        PRODUCT = 'bibdk-backend'
        // branch name to use in build
        BRANCH = BRANCH_NAME.replaceAll('feature/', '').replaceAll('_', '-')
        // artifactory buildname
        BUILDNAME = "Bibdk-backend :: ${BRANCH}"
        // GITLAB id for deploy job (where to set the image(build) number
        GITLABID = "708"
        // hmm why metascrum - well fix it later
        GITLAB_PRIVATE_TOKEN = credentials("metascrum-gitlab-api-token")
        // buildnumber
        //BUILDNUMBER = currentBuild.number
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
                script {
                    currentBuild.description = "Build ${BUILDNAME}:${currentBuild.number}"
                }

                script {
                    wwwImage = docker.build("${DOCKER_REPO}/${PRODUCT}-www-${BRANCH}:${currentBuild.number}",
                            "--build-arg BRANCH=${BRANCH_NAME} .")
                }

            }
        }
        stage('Docker db') {
            steps {
                dir('db') {
                    script {
                        dbImage = docker.build("${DOCKER_REPO}/${PRODUCT}-db-${BRANCH}:${currentBuild.number}",
                                "--no-cache .")
                    }
                }
            }
        }

        stage('Docker: push') {
            steps {
                script {
                    // @TODO - new artifactory server : docker-frontend.artifacts.dbccloud.dk
                    if (currentBuild.resultIsBetterOrEqualTo('SUCCESS')) {
                        docker.withRegistry('https://docker-frontend.artifacts.dbccloud.dk', 'docker') {
                            wwwImage.push()
                            if (BRANCH == "develop") {
                                dbImage.push();
                                wwwImage.push("latest")
                            }
                        }
                    }
                }

            }
        }

        stage("Update develop version number (deploy)") {
            agent {
                docker {
                    label 'devel10-head'
                    image "docker-dbc.artifacts.dbccloud.dk/build-env:latest"
                    alwaysPull true
                }
            }
            when {
                branch "master"
            }
            steps {
                dir("deploy") {
                    sh """#!/usr/bin/env bash
						set-new-version drupal-deployment-ready.yml ${env.GITLAB_PRIVATE_TOKEN} ${env.GITLABID} ${currentBuild.number} -b ${env.BRANCH}
                        set-new-version postgres-deployment-ready.yml ${env.GITLAB_PRIVATE_TOKEN} ${env.GITLABID} ${currentBuild.number} -b ${env.BRANCH}
					"""
                }
            }
        }


        stage('docker cleanup') {
            steps {
                script {
                    sh """
                    docker rmi ${DOCKER_REPO}/${PRODUCT}-www-${BRANCH}:${currentBuild.number}
                    docker rmi ${DOCKER_REPO}/${PRODUCT}-db-${BRANCH}:${currentBuild.number}
                    """
                    if (BRANCH == "develop") {
                        sh """
                        docker rmi ${DOCKER_REPO}/${PRODUCT}-www-${BRANCH}:latest
                        """
                    }
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
