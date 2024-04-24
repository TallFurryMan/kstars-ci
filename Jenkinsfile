def (INDI_BUILD_AMD64, INDI_BUILD_I386, INDI_BUILD_ATOM) = [null,null,null]
def (STSLV_BUILD_AMD64, STSLV_BUILD_I386, STSLV_BUILD_ATOM) = [null,null,null]
pipeline {
    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        disableConcurrentBuilds() // Observatory CI has many cores but too few memory
    }
    agent {
        label 'master'
    }
    parameters {
        persistentString(name: 'KSTARS_BRANCH', defaultValue: 'master', description: 'KStars branch to build.')
        persistentString(name: 'KSTARS_TAG',    defaultValue: '',       description: 'KStars tag to build.')
        persistentString(name: 'STSLV_BRANCH',  defaultValue: 'master', description: 'StellarSolver branch to build.')
        persistentString(name: 'STSLV_TAG',     defaultValue: '',       description: 'StellarSolver tag to build.')
        persistentString(name: 'INDI_BRANCH',   defaultValue: 'master', description: 'INDI branch to build.')
        persistentString(name: 'INDI_TAG',      defaultValue: '',       description: 'INDI tag to build.')
        persistentString(name: 'INDI3P_BRANCH', defaultValue: 'master', description: 'INDI 3rd Party branch to build.')
        persistentString(name: 'INDI3P_TAG',    defaultValue: '',       description: 'INDI 3rd Party tag to build.')
        persistentString(name: 'PHD2_BRANCH',   defaultValue: 'master', description: 'PHD2 tag to build.')
        persistentString(name: 'PHD2_TAG',      defaultValue: '',       description: 'PHD2 tag to build.')
    }
    stages {
        stage('Dependencies') {
            steps {
                parallel(
                    'indi-amd64': {
                        script {
                            def build = build job: 'amd64-indi', parameters: [
                                string(name: 'BRANCH', value: "${params.INDI_BRANCH}"),
                                string(name: 'TAG', value: "${params.INDI_TAG}"),
                                string(name: 'BRANCH3P', value: "${params.INDI3P_BRANCH}"),
                                string(name: 'TAG3P', value: "${params.INDI3P_TAG}")]
                            INDI_BUILD_AMD64 = build.getNumber()
                        }
                    },
                    'indi-i386': {
                        script {
                            def build = build job: 'i386-indi', parameters: [
                                string(name: 'BRANCH', value: "${params.INDI_BRANCH}"),
                                string(name: 'TAG', value: "${params.INDI_TAG}"),
                                string(name: 'BRANCH3P', value: "${params.INDI3P_BRANCH}"),
                                string(name: 'TAG3P', value: "${params.INDI3P_TAG}")]
                            INDI_BUILD_I386 = build.getNumber()
                        }
                    },
                    'indi-atom': {
                        script {
                            def build = build job: 'atom-indi', parameters: [
                                string(name: 'BRANCH', value: "${params.INDI_BRANCH}"),
                                string(name: 'TAG', value: "${params.INDI_TAG}"),
                                string(name: 'BRANCH3P', value: "${params.INDI3P_BRANCH}"),
                                string(name: 'TAG3P', value: "${params.INDI3P_TAG}")]
                            INDI_BUILD_ATOM = build.getNumber()
                        }
                    },
                    'stellarsolver-amd64': {
                        script {
                            def build = build job: 'amd64-stellarsolver', parameters: [
                                string(name: 'BRANCH', value: "${params.STSLV_BRANCH}"),
                                string(name: 'TAG', value: "${params.STSLV_TAG}")]
                            STSLV_BUILD_AMD64 = build.getNumber()
                        }
                    },
                    'stellarsolver-i386': {
                        script {
                            def build = build job: 'i386-stellarsolver', parameters: [
                                string(name: 'BRANCH', value: "${params.STSLV_BRANCH}"),
                                string(name: 'TAG', value: "${params.STSLV_TAG}")]
                            STSLV_BUILD_I386 = build.getNumber()
                        }
                    },
                    'stellarsolver-atom': {
                        script {
                            def build = build job: 'atom-stellarsolver', parameters: [
                                string(name: 'BRANCH', value: "${params.STSLV_BRANCH}"),
                                string(name: 'TAG', value: "${params.STSLV_TAG}")]
                            STSLV_BUILD_ATOM = build.getNumber()
                        }
                    }
                )
            }
        }
        stage('Build') {
            steps {
                parallel(
                    'kstars-amd64': {
                        build job: 'amd64',
                        parameters: [
                            string(name: 'BRANCH', value: "${params.KSTARS_BRANCH}"),
                            string(name: 'TAG', value: "${params.KSTARS_TAG}"),
                            string(name: 'INDI_CORE_BUILD', value: "${INDI_BUILD_AMD64}"),
                            string(name: 'STELLARSOLVER_BUILD', value: "${STSLV_BUILD_AMD64}")
                        ]
                    },
                    /* Can't build this anymore, needs cmake 3.16 which apparently does not exist on i386
                    'kstars-i386': {
                        build job: 'i386',
                        parameters: [
                            string(name: 'BRANCH', value: "${params.KSTARS_BRANCH}"),
                            string(name: 'TAG', value: "${params.KSTARS_TAG}"),
                            string(name: 'INDI_CORE_BUILD', value: "${INDI_BUILD_AMD64}"),
                            string(name: 'STELLARSOLVER_BUILD', value: "${STSLV_BUILD_AMD64}")
                        ]
                    }, */
                    'kstars-atom': {
                        build job: 'atom',
                        parameters: [
                            string(name: 'BRANCH', value: "${params.KSTARS_BRANCH}"),
                            string(name: 'TAG', value: "${params.KSTARS_TAG}"),
                            string(name: 'INDI_CORE_BUILD', value: "${INDI_BUILD_AMD64}"),
                            string(name: 'STELLARSOLVER_BUILD', value: "${STSLV_BUILD_AMD64}")
                        ]
                    },
                    'phd2-amd64': {
                        build job: 'amd64-phd2',
                        parameters: [
                            string(name: 'BRANCH', value: "${params.PHD2_BRANCH}"),
                            string(name: 'TAG', value: "${params.PHD2_TAG}")
                        ]
                    },
                    'phd2-i386': {
                        build job: 'i386-phd2',
                        parameters: [
                            string(name: 'BRANCH', value: "${params.PHD2_BRANCH}"),
                            string(name: 'TAG', value: "${params.PHD2_TAG}")
                        ]
                    },
                    'phd2-atom': {
                        build job: 'atom-phd2',
                        parameters: [
                            string(name: 'BRANCH', value: "${params.PHD2_BRANCH}"),
                            string(name: 'TAG', value: "${params.PHD2_TAG}")
                        ]
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
                    },
                    'Panda': {
                        build job: 'observatory-panda-update'
                    }
                )
            }
        }
    }
}
