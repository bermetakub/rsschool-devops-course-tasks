pipeline {
    agent {
        kubernetes {
            label 'docker-build'
            yaml """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins
  containers:
  - name: jenkins-agent
    image: jenkins/inbound-agent:latest
    command:
    - cat
    tty: true
    securityContext:
      privileged: true
  - name: docker
    image: docker:dind
    securityContext:
      privileged: true
  - name: helm
    image: alpine/helm:3.11.1  # Helm container
    command: ['cat']
    tty: true
"""
        }
    }
    environment {
        AWS_CREDENTIALS_ID = 'aws-ecr'
        AWS_ACCOUNT_ID = '211125355004'
        ECR_REPOSITORY = '211125355004.dkr.ecr.us-east-1.amazonaws.com/my-app'
        IMAGE_TAG = "latest"
        SONARQUBE_SCANNER = 'SonarQube Scanner'
        AWS_REGION = 'us-east-1'
        DOCKERFILE_REPO = 'https://github.com/bermetakub/rsschool-devops-course-tasks.git'
        DOCKERFILE_BRANCH = 'task_6'
        GIT_REPO = 'https://github.com/bermetakub/rsschool-devops-course-tasks.git' 
        GITHUB_REPO = 'https://github.com/bermetakub/rsschool-devops-course-tasks.git'
        GITHUB_BRANCH = 'task_6'
        SONARQUBE_URL = 'http://3.80.167.34:9000'  # Replace with your actual SonarQube URL
        SONARQUBE_TOKEN = credentials('eeb460fab172235f81f3bbda50f52bef888bfff7')  # Replace with your SonarQube authentication token
    }
    stages {
        stage('Checkout Dockerfile') {
            steps {
                git url: "${GITHUB_REPO}", branch: "${GITHUB_BRANCH}"
            }
         }       
        stage('Checkout Application Code') { 
            steps {
               git url: "${GIT_REPO}", branch: 'main'
            }
        }
        stage('Prepare Docker') {
            steps {
                container('docker') {
                    sh 'dockerd-entrypoint.sh &>/dev/null &' // Start Docker daemon
                    sh 'sleep 20'                            // Wait for Docker to initialize
                    sh 'apk add --no-cache aws-cli kubectl'  // Install AWS CLI and Helm
                    sh 'aws --version'                       // Verify AWS CLI installation
                    sh 'docker --version'                    // Verify Docker installation
                    sh 'kubectl version --client'            // Verify kubectl installation
                }
            }
        }
        stage('Unit Tests') {  
            steps {
                git url: "${GITHUB_REPO}", branch: "${GITHUB_BRANCH}" // Checkout here as well
                container('docker') {
                    sh "docker build -t my-app -f Dockerfile ."  
                }
            }
        }
        stage('SonarQube Security Check') {
            steps {
                container('sonar-scanner') {
                    sh """
                    sonar-scanner \
                        -Dsonar.projectKey=MyFirstProjectBermet \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=${SONARQUBE_URL} \
                        -Dsonar.login=${SONARQUBE_TOKEN}
                    """
                }
            }
        }
        stage('Application Build') {
            steps {
                container('docker') {
                    sh "docker build -t ${ECR_REPOSITORY}:${IMAGE_TAG} ."
                }
            }
        }
        stage('Push Docker Image to ECR') {
            when { expression { params.PUSH_TO_ECR == true } }
            steps {
                script {
                    if (currentBuild.result != 'FAILURE') {  //Capture success (or unstable)
                        env.PUSH_SUCCESSFUL = true
                    } else {
                        env.PUSH_SUCCESSFUL = false // Explicitly set to false on failure
                        }
                    container('docker') {
                        withCredentials([aws(credentialsId: "${AWS_CREDENTIALS_ID}")]) {
                            // Log in to ECR
                            sh """
                            aws ecr get-login-password --region ${AWS_REGION} | docker login -u AWS --password-stdin ${ECR_REPOSITORY}
                            """
                        }
                        // Push Docker image to ECR
                        sh "docker push ${ECR_REPOSITORY}:${IMAGE_TAG}"
                    }
                }
            }
        }
        stage('Create ECR Secret') {
            steps {
                container('docker') {
                    withCredentials([aws(credentialsId: "${AWS_CREDENTIALS_ID}")]) {
                        sh """
                        aws ecr get-login-password --region \${AWS_REGION} | docker login --username AWS --password-stdin \${ECR_REPOSITORY}

                        kubectl create secret generic ecr-secret --namespace=jenkins --from-file=.dockerconfigjson=\$HOME/.docker/config.json --dry-run=client -o json | kubectl apply -f -
                        """
                    }
                }
            }
        }
        stage('Deploy to Kubernetes with Helm') {
            when { expression { params.PUSH_TO_ECR == true } }
            steps {
                container('helm') {
                    sh """
                    helm upgrade --install word-cloud-generator ./helm/word-cloud-generator \\
                        --set image.repository=${ECR_REPOSITORY} \\
                        --set image.tag=${IMAGE_TAG} \\
                        -f ./helm/word-cloud-generator/values.yaml \\
                        --namespace jenkins
                    """
                }
            }
        }
    }    
    post {
        always {
            cleanWs()
            mail to: 'alymkulovabk@gmail.com',
            subject: "Jenkins Build: ${currentBuild.result}",
            body: "Job: ${env.JOB_NAME} \n Build Number: ${env.BUILD_NUMBER}"
        }
    }
}
   