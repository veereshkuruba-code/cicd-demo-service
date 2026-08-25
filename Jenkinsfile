
pipeline{
    agent any

    stages{
        stage('Verify workspace'){
            step{
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