pipeline {
    agent any

    environment {
        WEB_ROOT = '/var/www/html'
        HTML_FILE = 'index.html'
        DEPLOY_SCRIPT = './deploy-nginx.sh'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'ls -la'
            }
        }

        stage('Validate') {
            steps {
                sh '''
                    test -f "${HTML_FILE}"
                    grep -qi "<html" "${HTML_FILE}"
                    chmod +x "${DEPLOY_SCRIPT}"
                    sudo nginx -t
                '''
            }
        }

        stage('Deploy to Nginx') {
            steps {
                sh """
                    ${DEPLOY_SCRIPT} ./${HTML_FILE} ${WEB_ROOT}
                """
            }
        }

        stage('Verify') {
            steps {
                sh '''
                    curl -sf http://127.0.0.1/index.html | grep -q "NGINX Practice Website"
                    systemctl is-active nginx
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline succeeded: ${HTML_FILE} deployed to ${WEB_ROOT}."
        }
        failure {
            echo "Pipeline failed. Check console output and /var/log/nginx/error.log."
        }
    }
}
