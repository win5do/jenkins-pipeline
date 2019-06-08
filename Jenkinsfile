pipeline {
    agent any
    parameters {
        choice(name: 'REPO', choices: ['https://git.cardinfolink.net/Everonet/quickpay.git'])
        gitParameter(branchFilter: 'origin/(.*)', defaultValue: 'master', name: 'BRANCH', type: 'PT_BRANCH')
    }
    stages {
        stage('Example') {
            steps {
                git branch: "${params.BRANCH}", url: "${params.REPO}", credentialsId: 'woods.wu'
            }
        }
    }
}
