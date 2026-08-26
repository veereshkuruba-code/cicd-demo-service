
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

        stage('Copy Artifact to Application Server') {
            steps {
                sh '''
            echo "===== Jenkins Workspace ====="
            pwd

            echo
            echo "===== Source Artifact ====="
            ls -lh target/

            echo
            echo "===== Copying Artifact to Application Server ====="

            scp \
                -v \
                -o StrictHostKeyChecking=no \
                target/cicd-demo-service-0.0.1-SNAPSHOT.jar \
                deploy@16.171.206.195:/opt/cicd-demo-service/

            echo
            echo "===== Artifact Copy Completed ====="
        '''
            }
        }
    }
}