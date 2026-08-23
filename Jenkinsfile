pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Source code checked out successfully'
            }
        }

        stage('Build') {
            steps {
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
                sh './mvnw test'
            }
        }
    }
}