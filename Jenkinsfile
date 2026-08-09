// Jenkins CI/CD for the MERN microservices: build 3 images, push to Amazon ECR,
// then deploy to EKS with Helm.
pipeline {
    agent any

    environment {
        AWS_REGION   = 'ap-south-1'
        // Set these in Jenkins (Manage Jenkins > System or as credentials):
        //   AWS_ACCOUNT_ID, and AWS creds via the aws-credentials binding.
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_TAG    = "${env.BUILD_NUMBER}"
        CLUSTER_NAME = 'mern-eks'
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Build Images') {
            steps {
                sh '''
                    docker build -t $ECR_REGISTRY/mern-hello:$IMAGE_TAG    ./backend/helloService
                    docker build -t $ECR_REGISTRY/mern-profile:$IMAGE_TAG  ./backend/profileService
                    docker build -t $ECR_REGISTRY/mern-frontend:$IMAGE_TAG ./frontend
                '''
            }
        }

        stage('Login to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    sh '''
                        aws ecr get-login-password --region $AWS_REGION \
                          | docker login --username AWS --password-stdin $ECR_REGISTRY
                    '''
                }
            }
        }

        stage('Push Images') {
            steps {
                sh '''
                    docker push $ECR_REGISTRY/mern-hello:$IMAGE_TAG
                    docker push $ECR_REGISTRY/mern-profile:$IMAGE_TAG
                    docker push $ECR_REGISTRY/mern-frontend:$IMAGE_TAG
                '''
            }
        }

        stage('Deploy to EKS (Helm)') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    sh '''
                        aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION
                        helm upgrade --install mern ./helm/mern-app \
                          --set imageRegistry=$ECR_REGISTRY \
                          --set tag=$IMAGE_TAG \
                          --wait --timeout 5m
                    '''
                }
            }
        }
    }

    post {
        success { echo "Deployed build ${IMAGE_TAG} to EKS cluster ${CLUSTER_NAME}." }
        failure { echo "Pipeline failed at build ${IMAGE_TAG}. Check the console log." }
    }
}
