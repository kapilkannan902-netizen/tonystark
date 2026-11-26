pipeline {
    agent any

    environment {
        EC2_HOST = 'ubuntu@13.218.40.46'
    }

    options {
        timeout(time: 5, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    stages {
        stage('Validate') {
            steps {
                sh 'test -f index.html'
            }
        }
        stage('Deploy to EC2') {
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh 'scp -o StrictHostKeyChecking=no index.html $EC2_HOST:/var/www/html/index.html'
                }
            }
        }
        stage('Verify') {
            steps {
                sh 'curl -sf http://13.218.40.46 / > /dev/null'
            }
        }
    }

    post {
        success {
            echo 'Website deployed to EC2.'
        }
        failure {
            echo 'Deployment failed. Check the console output.'
        }
    }
}
