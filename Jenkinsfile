
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
    }
}