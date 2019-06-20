pipeline {
    agent any

    environment {
        GIT_CREID = 'win5do'
        REPO = 'https://github.com/win5do/go-hello-docker.git'
        CICD = 'https://github.com/win5do/jenkins-pipeline.git'
        VERSION = '1.0.0'
        REGISTRY_CREID = ''
        REGISTRY_URL = '127.0.0.1:5000'
        IMAGE_NAME = 'win5do/first'
    }

    parameters {
        choice(
                name: 'REPO',
                choices: ['https://github.com/win5do/go-hello-docker.git'],
        )
        gitParameter(
                branchFilter: 'origin/(.*)',
                defaultValue: 'master',
                name: 'BRANCH',
                type: 'PT_BRANCH',
        )
    }

    stages {
        stage('clone') {
            steps {
                git(
                        branch: "${params.BRANCH}",
                        url: "${REPO}",
                        credentialsId: "${GIT_CREID}",
                )

                dir('cicd') {
                    git(
                            branch: 'cicd',
                            url: "${CICD}",
                            credentialsId: "${GIT_CREID}",
                    )
                }
            }
        }

        stage('build') {
            steps {
                script {
                    // inside默认挂载当前workspace，并将其设置为workdir
                    docker.image('golang:1.12.5').inside() {
                        sh 'ls -l'
                        sh './build.sh'
                        sh 'cp cicd/Dockerfile .'
                        script {
                            def latestImage = docker.build("${IMAGE_NAME}:latest")
                            def versionImage = docker.build("${IMAGE_NAME}:${VERSION}")
                            docker.withRegistry("${REGISTRY_URL}") {
                                latestImage.push()
                                versionImage.push()
                            }
                        }
                    }
                }
            }
        }

        stage('deploy') {
            steps {
                dir('cicd') {
                    withCredentials([kubeconfigContent(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                        sh """
                        echo "$KUBECONFIG" > kubeconfig
                        ls -l
                        name='hello' image="${REGISTRY_URL}/${IMAGE_NAME}" ./tpl.sh
                        kubectl --kubeconfig=kubeconfig apply -f out/deploy.yaml
                    """
                    }
                }
            }
        }
    }
}
