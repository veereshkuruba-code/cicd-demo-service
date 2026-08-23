pipeline {
    agent any

    environment {
        APPLICATION_SERVER = '172.31.23.245'
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Source code checked out successfully'
            }
        }

        stage('Build') {
            steps {
                sh '''
                    chmod +x mvnw
                    ./mvnw clean package -DskipTests
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                    chmod +x mvnw
                    ./mvnw test
                '''
            }
        }

        stage('Verify Artifact') {
            steps {
                sh '''
                    echo "=== Build Artifacts ==="
                    ls -lh target/

                    echo "=== Verifying JAR ==="
                    test -f target/cicd-demo-service-*.jar
                '''
            }
        }

        stage('Test Application Server Connection') {
            steps {
                sshagent(credentials: ['application-server-ssh']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no \
                        deploy@${APPLICATION_SERVER} \
                        "hostname && whoami"
                    '''
                }
            }
        }

        stage('Pipeline Complete') {
            steps {
                echo 'CI pipeline and application server connectivity test completed successfully.'
            }
        }
    }
}