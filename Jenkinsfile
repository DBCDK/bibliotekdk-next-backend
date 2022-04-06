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
                        /*if (BRANCH == "develop"){
                            docker.build("${DOCKER_REPO}/${PRODUCT}-www-${BRANCH}:latest",
                                    "--build-arg BRANCH=${BRANCH_NAME} .")
                        }*/
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
                                wwwImage.push("latest")
                            }
                            dbImage.push();
                        }
                    }
                }

            }
        }

       /* stage('Docker: push') {
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

                    if (BRANCH == "develop"){
                        artyDocker.push("${DOCKER_REPO}/${PRODUCT}-www-${BRANCH}:latest", 'docker-dscrum')
                    }

                }
            }
        }*/
        stage('docker cleanup'){
            steps{
                script{
                    sh """
                    docker rmi ${DOCKER_REPO}/${PRODUCT}-www-${BRANCH}:${currentBuild.number}
                    docker rmi ${DOCKER_REPO}/${PRODUCT}-db-${BRANCH}:${currentBuild.number}
                    """
                    if (BRANCH == "develop"){
                        sh """
                        docker rmi ${DOCKER_REPO}/${PRODUCT}-www-${BRANCH}:latest
                        """
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                sh """ echo FISK """
                sh """ echo $BRANCH_NAME """
                /*script {
                    if (BRANCH == 'develop') {
                        build job: 'bibliotekdk-next/bibliotekdk-next-backend-deploy/develop'
                    } else if (BRANCH == 'master') {
                        build job: 'bibliotekdk-next/bibliotekdk-next-backend-deploy/staging'
                    } else {
                        build job: 'bibliotekdk-next/bibliotekdk-next-backend-deploy/develop', parameters: [string(name: 'deploybranch', value: BRANCH)]
                    }
                }*/
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
