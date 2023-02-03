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
        string(name: 'MYSQL_PORT', defaultValue: '33062', description: 'Mysql port number', trim: true)
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
                            sed 's/PASSWORD/$params.MYSQL_PASSWORD/g' include/create_developer.template > include/create_developer.sql
                        """
                        sh """
                            cat include/create_developer.sql
                        """
                        sh """
                            docker --version
                        """
                        sh """
                            docker build . -t $params.ENVIRONMENT_NAME:latest
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
                        docker run --name ${containerName} \
                            -e MYSQL_ROOT_PASSWORD=$params.MYSQL_PASSWORD \
                            -e MYSQL_DATABASE=mydatabase \
                            -e MYSQL_USER=developer \
                            -e MYSQL_PASSWORD=123456 \
                            -p $params.MYSQL_PORT:3306 \
                            -v /path/to/my.cnf:/etc/mysql/my.cnf \
                            -v /path/to/init-db.sh:/docker-entrypoint-initdb.d/init-db.sh \
                            -d $params.ENVIRONMENT_NAME:latest
                    """
                    echo "Docker container created: $containerName"
                }
            }
        }
    }
}
