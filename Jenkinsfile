
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
                echo "==== Making maven wrapper Executable===="
                chmod +x mvnw
                
                echo
                echo "====== maven version===="
                ./mvnw --version
                
                echo
                echo "=====git version===="
                git --version
                
                '''
            }
        }
    }
}