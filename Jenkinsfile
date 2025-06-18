pipeline {
    agent any
    environment {
        awsCreds = 'aws_credentials'
        dockerCreds = credentials('dockerhub_login') // used to get the username for next var
        registry = "${dockerCreds_USR}/vatcal"
        registryCredentials = "dockerhub_login"
        dockerImage = "" // empty var, will be written to later
    }
    stages {
        stage('Run Tests') {
            steps {
                npm 'install'
                npm 'test'
            }
        }
        stage('Build Image') {
            steps {
                script {
                    dockerImage = docker.build(registry)
                }
            }
        }
        stage('Generate Image reports') {
            steps {
                echo "====== Analysing image efficiency using dive ======"
                sh "CI=true dive ${dockerImage.imageName()}"
                echo "====== Analysing image vulnerabilities using grype ======"
                sh "grype ${dockerImage.imageName()} | head"
            }
        }
        stage('Push Image') {
            steps {
                script {
                    docker.withRegistry("", registryCredentials) {
                        dockerImage.push("${env.BUILD_NUMBER}")
                        dockerImage.push("latest")
                    }
                }
            }
        }
        stage('Clean up') {
            steps {
                sh "docker image prune --all --force --filter 'until=48h'" // ensure we don't accrue too many out-of-date images
            }
        }
        stage('Provision Server') {
            steps {
                script {
                    withCredentials([file(credentialsId: awsCreds, variable:'AWS_CREDENTIALS')]) {
                        sh 'rm credentials || true'
                        sh 'ln $AWS_CREDENTIALS credentials'
                        sh """echo 'creds_file = "credentials"' > terraform.tfvars"""
                        sh 'terraform init'
                        sh 'terraform apply'
                    }
                }
            }
        }
    }
}
