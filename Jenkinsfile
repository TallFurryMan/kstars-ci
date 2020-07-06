def INDI_BUILD
pipeline {
    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }
    agent {
        label 'master'
    }
    parameters {
        string(name: 'KSTARS_TAG', defaultValue: 'master', description: 'KStars tag to build.')
        string(name: 'INDI_TAG',   defaultValue: 'master', description: 'INDI tag to build.')
        string(name: 'INDI3P_TAG', defaultValue: 'master', description: 'INDI 3rd Party tag to build.')
        string(name: 'PHD2_TAG',   defaultValue: 'master', description: 'PHD2 tag to build.')
    }
    stages {
        stage('Dependencies') {
            steps {
                script {
                    def build = build job: 'i386-indi',
                        parameters: [string(name: 'TAG', value: "${params.INDI_TAG}"), string(name: 'TAG3P', value: "${params.INDI3P_TAG}")]
                    INDI_BUILD = build.getNumber()
                }
            }
        }
        stage('Build') {
            steps {
                parallel(
                    'kstars': {
                        build job: 'i386',
                              parameters: [string(name: 'TAG', value: "${params.KSTARS_TAG}"), string(name: 'INDI_CORE_BUILD', value: "${INDI_BUILD}")]
                    },
                    'phd2': {
                        build job: 'i386-phd2',
                              parameters: [string(name: 'TAG', value: "${params.PHD2_TAG}")]
                    }
                )
            }
        }
        stage('Install') {
            steps {
                parallel(
                    'Controller': {
                        build job: 'observatory-update'
                    },
                    'Guider': {
                        build job: 'observatory-guider-update'
                    }
                )
            }
        }
    }
}
