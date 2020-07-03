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
                build job: 'i386',
                    parameters: [string(name: 'BRANCH', value: '${parms.KSTARS_TAG}')]
            }
        }
        
        stage('Install') {
            steps {
                build job: 'observatory-update'
            }
        }
    }

}
