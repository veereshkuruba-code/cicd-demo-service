
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
    }
}