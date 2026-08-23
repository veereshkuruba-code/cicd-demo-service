pipeline {
    agent any

    environment {
        APP_NAME = 'cicd-demo-service'
        ARTIFACT_NAME = 'cicd-demo-service.jar'
    }

    stages {

        stage('Prepare') {
            steps {
                sh '''
                    chmod +x mvnw

                    echo "=== Java Version ==="
                    java -version
                '''
            }
        }

        stage('Build') {
            steps {
                sh './mvnw clean compile'
            }
        }

        stage('Test') {
            steps {
                sh './mvnw test'
            }
        }

        stage('Package') {
            steps {
                sh '''
                    ./mvnw package -DskipTests

                    cp target/${APP_NAME}-*.jar target/${ARTIFACT_NAME}
                '''
            }
        }

        stage('Verify Artifact') {
            steps {
                sh '''
                    echo "=== Build Artifacts ==="
                    ls -lh target/

                    test -f target/${ARTIFACT_NAME}

                    echo "Artifact verification successful."
                '''
            }
        }

        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: 'target/cicd-demo-service.jar', fingerprint: true
            }
        }
    }

    post {
        success {
            echo 'CI pipeline completed successfully.'
        }

        failure {
            echo 'CI pipeline failed.'
        }

        always {
            echo 'Pipeline execution completed.'
        }
    }
}