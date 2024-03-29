def NAME = 'hello'
def PORT = 5100
// xx.xx.xx.xx:5000/win5do/first:latest
def IMAGE_FULL_NAME = ''

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
        // REGISTRY_URL = 'http://192.168.99.1:5000'
        REGISTRY_URL = 'http://192.168.1.239:5000'
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
                        sh """
                            ls -l
                            workdir=`pwd`
                            ./build.sh
                            cd cicd/app
                            port="${PORT}" ./sedDockerfile.sh
                            cp out/Dockerfile \$workdir
                            cd \$workdir
                        """

                        script {
                            docker.withRegistry("${REGISTRY_URL}") {
                                def versionImage = docker.build("${IMAGE_NAME}:${VERSION}")
                                versionImage.push()
                                IMAGE_FULL_NAME = versionImage.imageName()
                            }
                        }
                        echo "${IMAGE_FULL_NAME}"
                    }
                }
            }
        }

        stage('deploy') {
            steps {
                dir('cicd/app') {
                    withCredentials([kubeconfigContent(credentialsId: 'kubeconfig', variable: 'KUBE_CONFIG')]) {
                        sh """
                            ls -l
                            name="${NAME}" image="${IMAGE_FULL_NAME}" port="${PORT}" ./sedDeploy.sh
                            deployFile=out/deploy.yaml
                            cat \$deployFile
                            echo "${KUBE_CONFIG}" > kubeconfig
                            kubectl --kubeconfig=kubeconfig apply -f \$deployFile
                        """
                    }
                }
            }
        }
    }
}
