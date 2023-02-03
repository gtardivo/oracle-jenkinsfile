//@Library("shared-library@master") _
pipeline {
    agent any
    options {
        disableConcurrentBuilds()
        disableResume()
    }
    parameters {
        string(name: 'ENVIRONMENT_NAME', defaultValue: 'teste', trim: true, description: '')
        password(name: 'MYSQL_PASSWORD', defaultValue: '123456', description: 'Password to use for MySQL container - root user')
        string(name: 'MYSQL_PORT', defaultValue: '3306', description: 'Mysql port number', trim: true)
        booleanParam(name: 'SKIP_STEP_1', defaultValue: false, description: 'STEP 1 - RE-CREATE DOCKER IMAGE')
    }
    stages {
        stage('Validate MYSQL_PORT') {
            steps {
                script {
                    def mysql_port_values = [3306, 33060, 33061]
                    def mysql_port = params.MYSQL_PORT.toInteger()
                    
                    if (!mysql_port_values.contains(mysql_port)) {
                        error("Invalid value for MYSQL_PORT. Valid values are: ${mysql_port_values.join(', ')}")
                    }
                }
            }
        }
        stage('Create latest Docker image') {
            steps {
                script {
                    if (!params.SKIP_STEP_1) {
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
                            docker build pipelines/ -t $params.ENVIRONMENT_NAME:latest
                        """
                    } else {
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
                        docker run -d -p $params.MYSQL_PORT:3306 --name ${containerName} -e MYSQL_ROOT_PASSWORD=$params.MYSQL_PASSWORD mysql:latest
                    """
                    sh """
                        sleep 20
                    """
                    sh """
                        docker logs ${containerName}
                    """
                    sh """
                        docker exec ${containerName} /bin/bash -c 'mysql --user="root" --password=$params.MYSQL_PASSWORD > /scripts/create_developer.sql'
                    """
                    echo "Docker container created: $containerName"
                }
            }
        }
    }
}
