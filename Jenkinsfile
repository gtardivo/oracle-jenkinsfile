//@Library("shared-library@master") _
pipeline {
        agent any
//      docker { image 'node:16.13.1-alpine' }
//      agent {
//         kubernetes {
//           activeDeadlineSeconds 60
//           cloud 'kubernetes'
//           defaultContainer 'jnlp'
//           idleMinutes 0          
//           yaml '''
// apiVersion: v1
// kind: Pod
// metadata:
//   labels:
//     br.com.bb.sigla: psc
//     br.com.bb.compilacao: false
//     br.com.bb.compilacao.linguagem: docker
//     br.com.bb.compilacao.versao: 18
// spec:
//   imagePullSecrets:
//   - name: atfregistry
//   tolerations:
//     - key: "papel.node.k8s.bb/workload"
//       operator: "Equal"
//       value: "true"
//       effect: "NoSchedule"
//   nodeSelector:
//     papel.node.k8s.bb/workload: true
//   slaveConnectTimeout: 180000
//   volumes:
//   - hostPath:
//       path: /var/run/docker.sock
//       type: ""
//     name: docker-socket-volume
//   - hostPath:
//       path: /var/tmp/jenkins_slave/
//       type: ""
//     name: temp-home-volume
//   containers:
//   - name: jnlp
//     image: atf.intranet.bb.com.br:5001/bb/aic/aic-jenkins-slave:3.30.0
//     tty: true
//     resources:
//       requests:
//         cpu: "250m"
//         memory: "512Mi"
//       limits:
//         cpu: "250m"
//         memory: "512Mi"
//   - name: deploy
//     image: atf.intranet.bb.com.br:5001/bb/psc/psc-helm:2.14.0
//     tty: true
//     resources:
//       requests:
//         cpu: "250m"
//         memory: "512Mi"
//       limits:
//         cpu: "250m"
//         memory: "512Mi"
//   - name: build
//     image: atf.intranet.bb.com.br:5001/bb/big/big-source-to-image:0.1.0
//     tty: true
//     resources:
//       requests:
//         cpu: "250m"
//         memory: "512Mi"
//       limits:
//         cpu: "250m"
//         memory: "512Mi"
//     securityContext:
//       privileged: true
//     volumeMounts:
//     - mountPath: /var/run/docker.sock
//       name: docker-socket-volume
//     command:
//     - cat
// '''
//}
  //  }
    options {
        disableConcurrentBuilds()
        disableResume()
    }

    //def mysql_port_values = [22,389,443,3306,6446,6447,6448,6449,33060,33061,11211]

    parameters {
      string(name: 'ENVIRONMENT_NAME', defaultValue: 'teste', trim: true, description: '')
      password(name: 'MYSQL_PASSWORD', defaultValue: '', description: 'Password to use for MySQL container - root user')
      string(name: 'MYSQL_PORT', defaultValue: '3306', description: 'Mysql port number', trim: true)
      booleanParam(name: 'SKIP_STEP_1', defaultValue: false, description: 'STEP 1 - RE-CREATE DOCKER IMAGE')
    }

    //def mysql_port = params.MYSQL_PORT.toInteger()

    // if (!mysql_port_values.contains(mysql_port)) {
    //   error("Invalid value for MYSQL_PORT. Valid values are: ${mysql_port_values.join(', ')}")
    // }

    stages {
        /*stage('Checkout GIT repository') {
            steps {     
              script {
                git branch: 'master',
                credentialsId: '21f01d09-06da9cc35103',
                url: 'git@mysecret-nonexistent-repo/jenkins.git'
              }
            }
        }*/
        stage('Create latest Docker image') {
            steps {     
              script {
                if (!params.SKIP_STEP_1){    
                    echo "Creating docker image with name $params.ENVIRONMENT_NAME using port: $params.MYSQL_PORT"
                    sh """
                    sed 's/PASSWORD/$params.MYSQL_PASSWORD/g' pipelines/include/create_developer.template > pipelines/include/create_developer.sql
                    """
                    sh """
                    cat pipelines/include/create_developer.sql
                    """
                    sh """
                    docker --version
                    """
                    sh """
                    docker build pipelines/ -t $params.ENVIRONMENT_NAME:latest $params.MYSQL_PASSWORD
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
                docker run -d --name ${containerName} -e MYSQL_ROOT_PASSWORD=$params.MYSQL_PASSWORD -p $params.MYSQL_PORT:3306 $params.ENVIRONMENT_NAME:latest
                """
                sh """
                docker logs ${containerName}
                """
                //mysql -h 127.0.0.1 -p 3306 --user="root" --password="123456" > /scripts/create_developer.sql
                sh """
                docker exec ${containerName} /bin/bash -c 'cat /etc/mysql/my.cnf'
                """
                echo "Docker container created: $containerName"
              
              }
            }
        }
    }

}