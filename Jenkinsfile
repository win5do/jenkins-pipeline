// 192.168.99.1:5000/win5do/first:latest
def imageName = ''

pipeline {
    agent any

    environment {
        GIT_CREID = 'win5do'
        REPO = 'https://github.com/win5do/go-hello-docker.git'
        CICD = 'https://github.com/win5do/jenkins-pipeline.git'
        // ${env.BUILD_TAG}
        VERSION = '1.0.0'
        REGISTRY_CREID = ''
        // 应使用内网地址，jenkins和k8s都可以访问到
        REGISTRY_URL = 'http://192.168.99.1:5000'
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
                        sh '''
                            ls -l
                            ./build.sh
                            cp cicd/Dockerfile .
                        '''

                        script {
                            docker.withRegistry("${REGISTRY_URL}") {
                                def latestImage = docker.build("${IMAGE_NAME}:latest")
                                def versionImage = docker.build("${IMAGE_NAME}:${VERSION}")
                                latestImage.push()
                                versionImage.push()

                                imageName = latestImage.imageName()
                            }
                        }
                        echo "${imageName}"
                    }
                }
            }
        }

        stage('deploy') {
            steps {
                dir('cicd/app') {
                    withCredentials([kubeconfigContent(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                        sh """
                            ls -l
                            name='hello' image="${imageName}" ./tpl.sh
                            echo "${KUBECONFIG}" > kubeconfig
                            kubectl --kubeconfig=kubeconfig apply -f out/deploy.yaml
                        """
                    }
                }
            }
        }
    }
}
