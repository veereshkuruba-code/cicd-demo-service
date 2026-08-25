
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
    }
}