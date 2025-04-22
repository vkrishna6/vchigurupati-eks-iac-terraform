pipeline {
  agent {
    kubernetes {
      label 'terraform'
      defaultContainer 'terraform'
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: terraform
    image: hashicorp/terraform:light
    command:
    - cat
    tty: true
  - name: jnlp
    image: jenkins/inbound-agent
"""
    }
  }

  environment {
    AWS_ACCESS_KEY_ID = credentials('aws-access-key')  // Create in Jenkins Credentials
    AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
    AWS_DEFAULT_REGION = 'us-east-1'
  }

  stages {
    stage('Checkout') {
      steps {
        git credentialsId: 'github-creds', url: 'https://github.com/your-org/your-repo.git'
      }
    }

    stage('Terraform Init') {
      steps {
        sh 'terraform init'
      }
    }

    stage('Terraform Plan') {
      steps {
        sh 'terraform plan'
      }
    }

    stage('Terraform Apply') {
      steps {
        input message: "Approve Terraform Apply?"
        sh 'terraform apply -auto-approve'
      }
    }
  }
}
