//@Library("shared-library@master") _
pipeline {
    agent {
        kubernetes {
          activeDeadlineSeconds 60
          cloud 'kubernetes'
          defaultContainer 'jnlp'
          idleMinutes 0
          yaml "---
                apiVersion: v1
                kind: Pod
                metadata:
                  labels:
                    br.com.bb.sigla: psc
                    br.com.bb.compilacao: false
                    br.com.bb.compilacao.linguagem: docker
                    br.com.bb.compilacao.versao: 18
                spec:
                  imagePullSecrets:
                  - name: atfregistry
                  tolerations:
                    - key: 'papel.node.k8s.bb/workload'
                      operator: 'Equal'
                      value: 'true'
                      effect: 'NoSchedule'
                  nodeSelector:
                    papel.node.k8s.bb/workload: true
                  slaveConnectTimeout: 180000
                  volumes:
                  - hostPath:
                      path: /var/run/docker.sock
                      type: ''
                    name: docker-socket-volume
                  - hostPath:
                      path: /var/tmp/jenkins_slave/
                      type: ''
                    name: temp-home-volume
                  containers:
                  - name: jnlp
                    image: atf.intranet.bb.com.br:5001/bb/aic/aic-jenkins-slave:3.30.0
                    tty: true
                    resources:
                      requests:
                        cpu: '250m'
                        memory: '512Mi'
                      limits:
                        cpu: '250m'
                        memory: '512Mi'
                  - name: deploy
                    image: atf.intranet.bb.com.br:5001/bb/psc/psc-helm:2.14.0
                    tty: true
                    resources:
                      requests:
                        cpu: '250m'
                        memory: '512Mi'
                      limits:
                        cpu: '250m'
                        memory: '512Mi'
                  - name: build
                    image: atf.intranet.bb.com.br:5001/bb/big/big-source-to-image:0.1.0
                    tty: true
                    resources:
                      requests:
                        cpu: '250m'
                        memory: '512Mi'
                      limits:
                        cpu: '250m'
                        memory: '512Mi'
                    securityContext:
                      privileged: true
                    volumeMounts:
                    - mountPath: /var/run/docker.sock
                      name: docker-socket-volume
                    command:
                    - cat
                  "
          }
    }
    options {
        disableConcurrentBuilds()
        disableResume()
    }

    parameters {
        string name: 'ENVIRONMENT_NAME', trim: true
        password defaultValue: '', description: 'Password to use for MySQL container - root user', name: 'MYSQL_PASSWORD'
        string name: 'MYSQL_PORT', trim: true

        booleanParam(name: 'SKIP_STEP_1', defaultValue: false, description: 'STEP 1 - RE-CREATE DOCKER IMAGE')
    }
  
    stages {
        stage('Checkout GIT repository') {
            steps {     
              script {
                git branch: 'master',
                credentialsId: '21f01d09-06da9cc35103',
                url: 'git@mysecret-nonexistent-repo/jenkins.git'
              }
            }
        }
        stage('Create latest Docker image') {
            steps {     
              script {
                if (!params.SKIP_STEP_1){    
                    echo "Creating docker image with name $params.ENVIRONMENT_NAME using port: $params.MYSQL_PORT"
                    sh """
                    sed 's/<PASSWORD>/$params.MYSQL_PASSWORD/g' pipelines/include/create_developer.template > pipelines/include/create_developer.sql
                    """

                    sh """
                    docker build pipelines/ -t $params.ENVIRONMENT_NAME:latest
                    """

                }else{
                    echo "Skipping STEP1"
                }
              }
            }
        }
        stage('Start new container using latest image and create user') {
            steps {     
              script {
                
                def dateTime = (sh(script: "date +%Y%m%d%H%M%S", returnStdout: true).trim())
                def containerName = "${params.ENVIRONMENT_NAME}_${dateTime}"
                sh """
                docker run -itd --name ${containerName} --rm -e MYSQL_ROOT_PASSWORD=$params.MYSQL_PASSWORD -p $params.MYSQL_PORT:3306 $params.ENVIRONMENT_NAME:latest
                """

                sh """
                docker exec ${containerName} /bin/bash -c 'mysql --user="root" --password="$params.MYSQL_PASSWORD" < /scripts/create_developer.sql'
                """

                echo "Docker container created: $containerName"

              }
            }
        }
    }

}    