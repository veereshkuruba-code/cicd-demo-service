pipeline {
    agent any

    environment {
        APP_NAME = 'cicd-demo-service'
        APP_SERVER = '16.171.206.195'
        DEPLOY_USER = 'deploy'
        DEPLOY_BASE_DIR = '/opt/cicd-demo-service'
    }

    stages {

        stage('Verify Workspace') {
            steps {
                sh '''
                    echo "===== Current Directory ====="
                    pwd

                    echo
                    echo "===== Workspace Contents ====="
                    ls -la
                '''
            }
        }

        stage('Verify Build Environment') {
            steps {
                sh '''
                    echo "===== Java Version ====="
                    java --version

                    echo
                    echo "===== Making Maven Wrapper Executable ====="
                    chmod +x mvnw

                    echo
                    echo "===== Maven Version ====="
                    ./mvnw --version

                    echo
                    echo "===== Git Version ====="
                    git --version
                '''
            }
        }

        stage('Compile Application') {
            steps {
                sh '''
                    echo "===== Compiling Application ====="

                    ./mvnw clean compile
                '''
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                    echo "===== Running Tests ====="

                    ./mvnw test

                    echo
                    echo "===== Test Reports Generated ====="

                    ls -la target/surefire-reports/
                '''
            }
        }

        stage('Build Application') {
            steps {
                sh '''
                    echo "===== Building Application ====="

                    ./mvnw clean package -DskipTests

                    echo
                    echo "===== Build Completed Successfully ====="
                '''
            }
        }

        stage('Verify Build Artifact') {
            steps {
                script {
                    def jarFile = sh(
                            script: '''
                            find target \
                                -maxdepth 1 \
                                -type f \
                                -name 'cicd-demo-service-*.jar' \
                                ! -name '*.original' \
                                | head -n 1
                        ''',
                            returnStdout: true
                    ).trim()

                    if (!jarFile) {
                        error('Application JAR not found')
                    }

                    env.JAR_FILE = jarFile

                    sh '''
                        echo "===== Verifying Build Artifact ====="

                        echo
                        echo "Application JAR:"
                        echo "$JAR_FILE"

                        echo
                        echo "===== Artifact Details ====="
                        ls -lh "$JAR_FILE"

                        echo
                        echo "===== SHA-256 Checksum ====="
                        sha256sum "$JAR_FILE"
                    '''
                }
            }
        }

        stage('Archive Artifact') {
            steps {
                archiveArtifacts(
                        artifacts: 'target/cicd-demo-service-*.jar',
                        excludes: 'target/*.jar.original',
                        fingerprint: true
                )
            }
        }

        stage('Prepare Deployment') {
            steps {
                script {
                    env.RELEASE_VERSION = "1.0.0-build-${BUILD_NUMBER}"
                    env.RELEASE_DIR = "${DEPLOY_BASE_DIR}/releases/${RELEASE_VERSION}"

                    echo "===== Deployment Details ====="
                    echo "Release Version: ${env.RELEASE_VERSION}"
                    echo "Release Directory: ${env.RELEASE_DIR}"
                }
            }
        }

        stage('Test Application Server Connection') {
            steps {
                sh '''
                    echo "===== Testing Application Server Connection ====="

                    ssh \
                        -o StrictHostKeyChecking=no \
                        ${DEPLOY_USER}@${APP_SERVER} \
                        "whoami && hostname"
                '''
            }
        }

        stage('Prepare Remote Release Directory') {
            steps {
                sh '''
                    echo "===== Preparing Remote Release Directory ====="

                    ssh \
                        -o StrictHostKeyChecking=no \
                        ${DEPLOY_USER}@${APP_SERVER} \
                        "
                            mkdir -p ${RELEASE_DIR}

                            echo 'Release directory created:'
                            ls -ld ${RELEASE_DIR}
                        "
                '''
            }
        }

        stage('Deploy Release Artifact') {
            steps {
                sh '''
                    echo "===== Deploying Release Artifact ====="

                    echo "Source Artifact:"
                    echo "$JAR_FILE"

                    echo
                    echo "Destination:"
                    echo "${DEPLOY_USER}@${APP_SERVER}:${RELEASE_DIR}/cicd-demo-service.jar"

                    scp \
                        -o StrictHostKeyChecking=no \
                        "$JAR_FILE" \
                        ${DEPLOY_USER}@${APP_SERVER}:${RELEASE_DIR}/cicd-demo-service.jar

                    echo
                    echo "===== Artifact Copy Completed Successfully ====="
                '''
            }
        }

        stage('Verify Remote Artifact') {
            steps {
                sh '''
                    echo "===== Verifying Remote Artifact ====="

                    ssh \
                        -o StrictHostKeyChecking=no \
                        ${DEPLOY_USER}@${APP_SERVER} \
                        "
                            echo '===== Release Directory ====='
                            ls -lh ${RELEASE_DIR}

                            echo
                            echo '===== Checking Application JAR ====='

                            test -f ${RELEASE_DIR}/cicd-demo-service.jar

                            echo 'Application JAR verified successfully'

                            echo
                            echo '===== Artifact Details ====='
                            ls -lh ${RELEASE_DIR}/cicd-demo-service.jar

                            echo
                            echo '===== SHA-256 Checksum ====='
                            sha256sum ${RELEASE_DIR}/cicd-demo-service.jar
                        "
                '''
            }
        }

        stage('Activate Release') {
            steps {
                sh '''
            echo "===== Activating Release ====="

            ssh \
                -o StrictHostKeyChecking=no \
                ${DEPLOY_USER}@${APP_SERVER} \
                "
                    cd ${DEPLOY_BASE_DIR}

                    ln -sfn releases/${RELEASE_VERSION} current

                    echo '===== Active Release ====='
                    ls -l current
                    readlink -f current
                "
        '''
            }
        }
    }
}