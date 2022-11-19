pipeline {
    agent any 
    stages {
        stage('Build') { 
            steps {
                echo 'BUILD'
            }
        }
        stage('Test') { 
            steps {
                echo 'TEST'
            }
        }
        stage('Deploy') { 
            steps {
                echo 'DEPLOY'
            }
        }
    }
}