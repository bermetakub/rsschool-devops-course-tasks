pipeline {
    agent {
        kubernetes {
            label 'prometheus-deploy'
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
  - name: helm
    image: alpine/helm:3.11.1
    command: ['cat']
    tty: true
"""
        }
    }
    environment {
        AWS_CREDENTIALS_ID = 'aws-ecr'
        AWS_REGION = 'us-east-1'
        KUBE_NAMESPACE = 'monitoring'
        HELM_RELEASE_NAME = 'prometheus'
        HELM_CHART_REPO = 'https://prometheus-community.github.io/helm-charts'
        HELM_CHART_NAME = 'kube-prometheus-stack'
    }
    stages {
        stage('Prepare Kubernetes Environment') {
            steps {
                container('helm') {
                    sh """
                    # Add Helm repository for Prometheus
                    helm repo add prometheus-community ${HELM_CHART_REPO}
                    helm repo update
                    """
                }
            }
        }
        stage('Deploy Prometheus with Helm') {
            steps {
                container('helm') {
                    sh """
                    helm upgrade --install ${HELM_RELEASE_NAME} ${HELM_CHART_NAME} \\
                        --namespace ${KUBE_NAMESPACE} \\
                        --create-namespace \\
                        -f ./values.yaml
                    """
                }
            }
        }
        stage('Validate Prometheus Deployment') {
            steps {
                container('helm') {
                    sh "kubectl get pods -n ${KUBE_NAMESPACE}"
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

   