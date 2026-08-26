
pipeline{
    agent any

    stages{
        stage('Verify workspace'){
            steps{
                sh'''
                    
                    echo "=====current directory====="
                    pwd
                    echo "Workspace Contents"
                    
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

            ls -la target/surefire-reports/ || true
        '''
            }
        }

        stage('Build Application'){

            steps{
                sh'''
                    echo "====Building Application"
                    ./mvnw clean package -DskipTests
                    
                    echo 
                    echo "===== Build Completed Successfully ====="
                '''
            }
        }

        stage('Verify Artifact') {

            steps {

                sh '''
            echo "===== Verifying Build Artifact ====="

            echo
            echo "===== Target Directory Contents ====="
            ls -lh target/

            echo
            echo "===== Checking Application JAR ====="

            JAR_FILE=$(find target \
                -maxdepth 1 \
                -type f \
                -name 'cicd-demo-service-*.jar' \
                ! -name '*.original' \
                | head -n 1)

            if [ -z "$JAR_FILE" ]; then
                echo "ERROR: Application JAR not found"
                exit 1
            fi

            echo "Application JAR found:"
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

                    env.RELEASE_VERSION =
                            "1.0.0-build-${BUILD_NUMBER}"

                    echo "Release Version: ${env.RELEASE_VERSION}"
                }
            }
        }

        stage('Test Application Server Connection') {
            steps {
                sh '''
            ssh \
              -o StrictHostKeyChecking=no \
              deploy@16.171.206.195 \
              "whoami && hostname"
        '''
            }
        }

        stage('Deploy Release Artifact') {
            steps {
                sh '''
            RELEASE_DIR="/opt/cicd-demo-service/releases/${RELEASE_VERSION}"

            echo "===== Preparing Release Directory ====="
            echo "Release Version: ${RELEASE_VERSION}"
            echo "Release Directory: ${RELEASE_DIR}"

            ssh \
              -o StrictHostKeyChecking=no \
              deploy@16.171.206.195 \
              "mkdir -p ${RELEASE_DIR}"

            echo
            echo "===== Copying Artifact ====="

            scp \
              -o StrictHostKeyChecking=no \
              target/cicd-demo-service-0.0.1-SNAPSHOT.jar \
              deploy@16.171.206.195:${RELEASE_DIR}/cicd-demo-service.jar

            echo
            echo "===== Release Artifact Copied Successfully ====="
        '''
            }
        }

        stage('Verify Remote Artifact') {
            steps {
                sh '''
            ssh \
              -o StrictHostKeyChecking=no \
              deploy@16.171.206.195 \
              "
                echo '===== Remote Artifact Verification ====='

                echo
                echo '===== Deployment Directory ====='
                ls -lh /opt/cicd-demo-service/

                echo
                echo '===== Checking Application JAR ====='

                test -f /opt/cicd-demo-service/cicd-demo-service-0.0.1-SNAPSHOT.jar

                echo 'Application JAR verified successfully'

                echo
                echo '===== Artifact Details ====='
                ls -lh /opt/cicd-demo-service/cicd-demo-service-0.0.1-SNAPSHOT.jar

                echo
                echo '===== SHA-256 Checksum ====='
                sha256sum /opt/cicd-demo-service/cicd-demo-service-0.0.1-SNAPSHOT.jar
              "
        '''
            }
        }
    }
}