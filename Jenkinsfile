pipeline {
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }
    
    agent {
        dockerfile {
            filename 'Dockerfile'
            args '-v kstars_workspace:/home/jenkins/workspace -v ccache:/home/jenkins/.ccache --group-add sudo'
        }
    }
    
    parameters {
        persistentString(name: 'REPO',   defaultValue: env.PHD2_GIT ?: 'https://github.com/agalasso/phdlogview.git', description: 'The repository to clone from.')
        persistentString(name: 'BRANCH', defaultValue: 'master', description: 'The repository branch to build.')
        persistentString(name: 'TAG',    defaultValue: 'v0.6.3', description: 'The repository tag to build.')
    }

    environment {
        CCACHE_COMPRESS = '1'
    }

    stages {
        
        stage('Preparation') {
            steps {
                sh 'cat ~/built_on'
                sh '[ -f ~/.ccache/ccache.conf ] || touch ~/.ccache/ccache.conf'
                sh 'ccache --max-size 20G'
                sh 'ccache -s'
                sh '''
                    printf "%s\\n" \
                      "SET(CMAKE_SYSTEM_NAME Linux)" \
                      "SET(CMAKE_SYSTEM_PROCESSOR x86_64)" \
                      "SET(CMAKE_C_COMPILER gcc)" \
                      "SET(CMAKE_C_FLAGS -march=x86-64)" \
                      "SET(CMAKE_CXX_COMPILER g++)" \
                      "SET(CMAKE_CXX_FLAGS -march=x86-64)" > ~/amd64.cmake
                '''
                sh 'cmake --version'
            }
        }

        stage('Checkout') {
            steps {
                checkout([
                  $class: 'GitSCM',
                  userRemoteConfigs: [[ url: params.REPO ]],
                  branches: [[ name: params.BRANCH ]],
                  extensions: [[ $class: 'CloneOption', shallow: true, depth: 1, timeout: 60 ]],
                ])
                sh "if [ -n '${params.TAG}' -a '${params.BRANCH}' != '${params.TAG}' ] ; then git checkout '${params.TAG}' ; fi"
                sh "git log --oneline --decorate -10"
            }
        }

        stage('Build') {
            steps {
                dir('phdlogview-build') {
                    deleteDir()
                    sh "cmake -DCMAKE_TOOLCHAIN_FILE=~/amd64.cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCCACHE_SUPPORT=ON -DHAVE_WXFB=FALSE ${env.WORKSPACE}"
                    sh "make -j4 clean all"
                }
            }
        }

        stage('Test') {
            steps {
                catchError (message:'Test Failure', buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    dir('phdlogview-build') {
                        sh 'make test'
                    }
                }
            }
        }
        
        stage('Package') {
            steps {
                dir('phdlogview-build') {
                    sh '''
                        rm -f phdlogview*.deb
                        version="$(grep -m 1 Version ChangeLog.txt | grep -o '[0-9.]*')"
                        version_patch=`git show HEAD | head -1 | cut -d' ' -f2 | cut -b-8`
                        package_file_name=\"phdlogview-$version.$version_patch-Linux-x86_64\"
                        cpack --debug --verbose \
                            -G DEB \
                            -P kstars \
                            -R $version \
                            -D CPACK_INSTALL_CMAKE_PROJECTS=\".;phdlogview;ALL;/\" \
                            -D CPACK_PACKAGING_INSTALL_PREFIX=/usr/local \
                            -D CPACK_PACKAGE_FILE_NAME=\"$package_file_name\" \
                            -D CPACK_PACKAGE_DESCRIPTION_FILE=../.git/HEAD \
                            -D CPACK_CMAKE_GENERATOR=\"Unix Makefiles\" \
                            -D CPACK_INSTALL_COMMANDS=\"make install\" \
                            -D CPACK_PACKAGE_CONTACT=\"https://github.com/TallFurryMan/kstars-ci\" \
                            -D CPACK_PACKAGE_DESCRIPTION_SUMMARY=\"PHD Log View amd64\" \
                            -D CPACK_DEBIAN_PACKAGE_ARCHITECTURE=amd64
                        dpkg --info \"$package_file_name.deb\"
                    '''
                    archiveArtifacts artifacts: 'phdlogview*.deb',
                                     fingerprint: true
                    deleteDir()
                }
            }
        }
    }
}
