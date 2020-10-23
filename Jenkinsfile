def INDI_BUILD
def STSLV_BUILD
pipeline {
    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        disableConcurrentBuilds() // Observatory CI has many cores but too few memory
    }
    agent {
        label 'master'
    }
    parameters {
        string(name: 'KSTARS_TAG', defaultValue: 'master', description: 'KStars tag to build.')
        string(name: 'STSLV_TAG',  defaultValue: 'master', description: 'StellarSolver tag to build.')
        string(name: 'INDI_TAG',   defaultValue: 'master', description: 'INDI tag to build.')
        string(name: 'INDI3P_TAG', defaultValue: 'master', description: 'INDI 3rd Party tag to build.')
        string(name: 'PHD2_TAG',   defaultValue: 'master', description: 'PHD2 tag to build.')
    }
    stages {
        stage('Dependencies') {
            steps {
                parallel(
                    'indi': {
                        script {
                            def build = build job: 'i386-indi', parameters: [
                                string(name: 'TAG', value: "${params.INDI_TAG}"),
                                string(name: 'TAG3P', value: "${params.INDI3P_TAG}")]
                            INDI_BUILD = build.getNumber()
                        }
                    },
                    'stellarsolver': {
                        script {
                            def build = build job: 'i386-stellarsolver', parameters: [
                                string(name: 'TAG', value: "${params.STSLV_TAG}")]
                            STSLV_BUILD = build.getNumber()
                        }
                    }
                )
            }
        }
        stage('Build') {
            steps {
                parallel(
                    'kstars': {
                        build job: 'i386',
                              parameters: [
                                  string(name: 'TAG', value: "${params.KSTARS_TAG}"),
                                  string(name: 'INDI_CORE_BUILD', value: "${INDI_BUILD}"),
                                  string(name: 'STELLARSOLVER_BUILD', value: "${STSLV_BUILD}")
                              ]
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
