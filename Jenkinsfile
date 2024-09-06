def (INDI_BUILD_AMD64, INDI_BUILD_I386, INDI_BUILD_ATOM) = [null,null,null]
def (STSLV_BUILD_AMD64, STSLV_BUILD_I386, STSLV_BUILD_ATOM) = [null,null,null]
def (KSTARS_BUILD_AMD64, KSTARS_BUILD_I386, KSTARS_BUILD_ATOM) = [null,null,null]
def (PHD2_BUILD_AMD64, PHD2_BUILD_I386, PHD2_BUILD_ATOM) = [null,null,null]
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
            stages {
                stage('indi-amd64') {
                    steps {
                        script {
                            def build = build job: 'amd64-indi', parameters: [
                                string(name: 'BRANCH', value: "${params.INDI_BRANCH}"),
                                string(name: 'TAG', value: "${params.INDI_TAG}"),
                                string(name: 'BRANCH3P', value: "${params.INDI3P_BRANCH}"),
                                string(name: 'TAG3P', value: "${params.INDI3P_TAG}")]
                            INDI_BUILD_AMD64 = build.getNumber()
                            copyArtifacts projectName: 'amd64-indi',
                                selector: specific("${INDI_BUILD_AMD64}"),
                                fingerprintArtifacts: true
                            archiveArtifacts artifacts: 'indi*.deb',
                                fingerprint: true
                        }
                    }
                }
                stage('indi-i386') {
                    steps {
                        script {
                            def build = build job: 'i386-indi', parameters: [
                                string(name: 'BRANCH', value: "${params.INDI_BRANCH}"),
                                string(name: 'TAG', value: "${params.INDI_TAG}"),
                                string(name: 'BRANCH3P', value: "${params.INDI3P_BRANCH}"),
                                string(name: 'TAG3P', value: "${params.INDI3P_TAG}")]
                            INDI_BUILD_I386 = build.getNumber()
                            copyArtifacts projectName: 'i386-indi',
                                selector: specific("${INDI_BUILD_I386}"),
                                fingerprintArtifacts: true
                            archiveArtifacts artifacts: 'indi*.deb',
                                fingerprint: true
                        }
                    }
                }
                stage('indi-atom') {
                    steps {
                        script {
                            def build = build job: 'atom-indi', parameters: [
                                string(name: 'BRANCH', value: "${params.INDI_BRANCH}"),
                                string(name: 'TAG', value: "${params.INDI_TAG}"),
                                string(name: 'BRANCH3P', value: "${params.INDI3P_BRANCH}"),
                                string(name: 'TAG3P', value: "${params.INDI3P_TAG}")]
                            INDI_BUILD_ATOM = build.getNumber()
                            copyArtifacts projectName: 'atom-indi',
                                selector: specific("${INDI_BUILD_ATOM}"),
                                fingerprintArtifacts: true
                            archiveArtifacts artifacts: 'indi*.deb',
                                fingerprint: true
                        }
                    }
                }
                stage('stellarsolver-amd64') {
                    steps {
                        script {
                            def build = build job: 'amd64-stellarsolver', parameters: [
                                string(name: 'BRANCH', value: "${params.STSLV_BRANCH}"),
                                string(name: 'TAG', value: "${params.STSLV_TAG}")]
                            STSLV_BUILD_AMD64 = build.getNumber()
                            copyArtifacts projectName: 'amd64-stellarsolver',
                                selector: specific("${STSLV_BUILD_AMD64}"),
                                fingerprintArtifacts: true
                            archiveArtifacts artifacts: 'stellarsolver*.deb',
                                fingerprint: true
                        }
                    }
                }
                /*stage('stellarsolver-i386') {
                    steps {
                        script {
                            def build = build job: 'i386-stellarsolver', parameters: [
                                string(name: 'BRANCH', value: "${params.STSLV_BRANCH}"),
                                string(name: 'TAG', value: "${params.STSLV_TAG}")]
                            STSLV_BUILD_I386 = build.getNumber()
                        }
                    }
                }*/
                stage('stellarsolver-atom') {
                    steps {
                        script {
                            def build = build job: 'atom-stellarsolver', parameters: [
                                string(name: 'BRANCH', value: "${params.STSLV_BRANCH}"),
                                string(name: 'TAG', value: "${params.STSLV_TAG}")]
                            STSLV_BUILD_ATOM = build.getNumber()
                            copyArtifacts projectName: 'atom-stellarsolver',
                                selector: specific("${STSLV_BUILD_ATOM}"),
                                fingerprintArtifacts: true
                            archiveArtifacts artifacts: 'stellarsolver*.deb',
                                fingerprint: true
                        }
                    }
                }
            }
        }
        stage('Build') {
            stages {
                stage('kstars-amd64') {
                    steps {
                        script {
                            def build = build job: 'amd64',
                                parameters: [
                                    string(name: 'BRANCH', value: "${params.KSTARS_BRANCH}"),
                                    string(name: 'TAG', value: "${params.KSTARS_TAG}"),
                                    string(name: 'INDI_CORE_BUILD', value: "${INDI_BUILD_AMD64}"),
                                    string(name: 'STELLARSOLVER_BUILD', value: "${STSLV_BUILD_AMD64}")
                                ]
                            KSTARS_BUILD_AMD64 = build.getNumber()
                            copyArtifacts projectName: 'amd64',
                                selector: specific("${KSTARS_BUILD_AMD64}"),
                                fingerprintArtifacts: true
                            archiveArtifacts artifacts: 'kstars*.deb',
                                fingerprint: true
                        }
                    }
                }
                /* Can't build this anymore, needs cmake 3.16 which apparently does not exist on i386
                stage('kstars-i386') {
                    build job: 'i386',
                    parameters: [
                        string(name: 'BRANCH', value: "${params.KSTARS_BRANCH}"),
                        string(name: 'TAG', value: "${params.KSTARS_TAG}"),
                        string(name: 'INDI_CORE_BUILD', value: "${INDI_BUILD_AMD64}"),
                        string(name: 'STELLARSOLVER_BUILD', value: "${STSLV_BUILD_AMD64}")
                    ]
                } */
                stage('kstars-atom') {
                    steps {
                        script {
                            def build = build job: 'atom',
                                parameters: [
                                    string(name: 'BRANCH', value: "${params.KSTARS_BRANCH}"),
                                    string(name: 'TAG', value: "${params.KSTARS_TAG}"),
                                    string(name: 'INDI_CORE_BUILD', value: "${INDI_BUILD_AMD64}"),
                                    string(name: 'STELLARSOLVER_BUILD', value: "${STSLV_BUILD_AMD64}")
                                ]
                            KSTARS_BUILD_ATOM = build.getNumber()
                            copyArtifacts projectName: 'atom',
                                selector: specific("${KSTARS_BUILD_ATOM}"),
                                fingerprintArtifacts: true
                            archiveArtifacts artifacts: 'kstars*.deb',
                                fingerprint: true
                        }
                    }
                }
                stage('phd2-amd64') {
                    steps {
                        script {
                            def build = build job: 'amd64-phd2',
                                parameters: [
                                    string(name: 'BRANCH', value: "${params.PHD2_BRANCH}"),
                                    string(name: 'TAG', value: "${params.PHD2_TAG}")
                                ]
                            PHD2_BUILD_AMD64 = build.getNumber()
                            copyArtifacts projectName: 'amd64-phd2',
                                selector: specific("${PHD2_BUILD_AMD64}"),
                                fingerprintArtifacts: true
                            archiveArtifacts artifacts: 'phd2*.deb',
                                fingerprint: true
                        }
                    }
                }
                /*stage('phd2-i386') {
                    steps {
                        script {
                            def build = build job: 'i386-phd2',
                                parameters: [
                                    string(name: 'BRANCH', value: "${params.PHD2_BRANCH}"),
                                    string(name: 'TAG', value: "${params.PHD2_TAG}")
                                ]
                            PHD2_BUILD_I386 = build.getNumber()
                            copyArtifacts projectName: 'i386-phd2',
                                selector: specific("${PHD2_BUILD_I386}"),
                                fingerprintArtifacts: true
                            archiveArtifacts artifacts: 'phd2*.deb',
                                fingerprint: true
                        }
                    }
                }*/
                stage('phd2-atom') {
                    steps {
                        script {
                            def build = build job: 'atom-phd2',
                                parameters: [
                                    string(name: 'BRANCH', value: "${params.PHD2_BRANCH}"),
                                    string(name: 'TAG', value: "${params.PHD2_TAG}")
                                ]
                            PHD2_BUILD_ATOM = build.getNumber()
                            copyArtifacts projectName: 'atom-phd2',
                                selector: specific("${PHD2_BUILD_ATOM}"),
                                fingerprintArtifacts: true
                            archiveArtifacts artifacts: 'phd2*.deb',
                                fingerprint: true
                        }
                    }
                }
            }
        }
    }
}
