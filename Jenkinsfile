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
        string(name: 'PHD2_TAG',   defaultValue: 'master', description: 'KStars tag to build.')
    }

    stages {
    
        stage('Build') {
            steps {
                parallel(
                    'kstars': {
                        build job: 'i386',
                              parameters: [string(name: 'BRANCH', value: '${params.KSTARS_TAG}')]
                    },
                    //'indi': {
                    //    build job: 'i386-indi',
                    //          parameters: [string(name: 'BRANCH', value: '${params.INDI_TAG}')]
                    //},
                    //'indi-3rd-party': {
                    //    build job: 'i386-indi3p',
                    //          parameters: [string(name: 'BRANCH', value: '${params.INDI3P_TAG}')]
                    //},
                    'phd2': {
                        build job: 'i386-phd2',
                              parameters: [string(name: 'BRANCH', value: '${params.PHD2_TAG}')]
                    }
                )
            }
        }
        
        stage('Install') {
            steps {
                build job: 'observatory-update'
            }
        }
    }

}
