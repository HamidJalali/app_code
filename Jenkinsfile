pipeline {
    agent any

    options {
        disableConcurrentBuilds()

        timestamps()

        timeout(
            time: 10,
            unit: 'MINUTES'
        )

        skipDefaultCheckout(true)

        disableResume()
    }

    environment {
        REMOTE_HOST = 'learning.private.internal'
        REMOTE_DIR = 'devops-case-study-practice/jenkins-checkout'
        REGISTRY = 'docker.io'
        IMAGE = 'hjcontainer/myapp'
        IMAGE_TAG = ''
    }

    stages {
        stage('Checkout') {
            steps {
                dir('/workspace/jenkins-checkout') {
                    git(
                        branch: 'main',
                        credentialsId: 'ssh-private-key',
                        url: 'git@github.com:HamidJalali/app_code.git'
                    )
                }
            }
        }

        stage('Determine Image Version') {
            steps {
                script {
                    def version = readFile('/workspace/jenkins-checkout/VERSION').trim()

                    if (!version) {
                        error('VERSION file is empty')
                    }

                    if (!(version ==~ /^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$/)) {
                        error("Invalid version: ${version}")
                    }

                    env.IMAGE_TAG = "${version}"
                    echo "Docker image IMAGE_TAG: ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Remote Docker Registry Login') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ssh-private-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    ),
                    file(
                        credentialsId: 'private-known-hosts',
                        variable: 'KNOWN_HOSTS'
                    ),
                    usernamePassword(
                        credentialsId: 'docker-registry',
                        usernameVariable: 'REGISTRY_USER',
                        passwordVariable: 'REGISTRY_PASSWORD'
                    )
                ]) {
                    sh '''
                        set -eu

                        printf '%s' "$REGISTRY_PASSWORD" | ssh \
                            -i "$SSH_KEY" \
                            -o BatchMode=yes \
                            -o UserKnownHostsFile="$KNOWN_HOSTS" \
                            "${SSH_USER}@${REMOTE_HOST}" \
                            "docker login ${REGISTRY} --username '${REGISTRY_USER}' --password-stdin"
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ssh-private-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    ),
                    file(
                        credentialsId: 'private-known-hosts',
                        variable: 'KNOWN_HOSTS'
                    )
                ]) {
                    sh '''
                        set -eu

                        ssh \
                            -i "$SSH_KEY" \
                            -o BatchMode=yes \
                            -o UserKnownHostsFile="$KNOWN_HOSTS" \
                            "${SSH_USER}@${REMOTE_HOST}" \
                            "cd /home/${SSH_USER}/${REMOTE_DIR} && \
                            docker build -t '${IMAGE}:${IMAGE_TAG}' -t '${IMAGE}:latest' ."
                    '''
                }
            }
        }

        stage('Scan and Push Docker Image') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ssh-private-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    ),
                    file(
                        credentialsId: 'private-known-hosts',
                        variable: 'KNOWN_HOSTS'
                    )
                ]) {
                    sh '''
                        set -eu

                        ssh \
                            -i "$SSH_KEY" \
                            -o BatchMode=yes \
                            -o UserKnownHostsFile="$KNOWN_HOSTS" \
                            "${SSH_USER}@${REMOTE_HOST}" \
                            "/home/${SSH_USER}/.local/bin/trivy image --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 '${IMAGE}:${IMAGE_TAG}'"

                        ssh \
                            -i "$SSH_KEY" \
                            -o BatchMode=yes \
                            -o UserKnownHostsFile="$KNOWN_HOSTS" \
                            "${SSH_USER}@${REMOTE_HOST}" \
                            "docker push '${IMAGE}:${IMAGE_TAG}' && docker push '${IMAGE}:latest'"
                    '''
                }
            }
        }
    }

    post {
        always {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ssh-private-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    ),
                    file(
                        credentialsId: 'private-known-hosts',
                        variable: 'KNOWN_HOSTS'
                    )
                ]) {
                    sh '''
                        set -eu

                        ssh \
                            -i "$SSH_KEY" \
                            -o BatchMode=yes \
                            -o UserKnownHostsFile="$KNOWN_HOSTS" \
                            "${SSH_USER}@${REMOTE_HOST}" \
                            "docker rmi '${IMAGE}:${IMAGE_TAG}' '${IMAGE}:latest' || true"
                    '''
                }
        }
    }
}
