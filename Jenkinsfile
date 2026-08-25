
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

        stage('Verify Build Environment'){

            steps{

                sh'''
                echo "====java version====="
                java --version
                
                echo
                echo "====== maven version===="
                ./mvn --version
                
                echo
                echo "=====git version===="
                git --version
                
                '''
            }
        }
    }
}