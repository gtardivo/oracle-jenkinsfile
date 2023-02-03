#!/usr/bin/env groovy

node {
    stage('Checkout code') {
        checkout scm
    }
    stage('Build Docker image') {
        sh 'docker build -t myapp:latest .'
    }
    stage('Run Docker container') {
        sh 'docker run -d -p 3306:3306 --name myapp-dev-container -e MYSQL_ROOT_PASSWORD=rootpassword myapp:latest'
    }
}
