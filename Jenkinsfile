pipeline {
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }
    
    agent {
        dockerfile {
            filename 'Dockerfile'
            args '-v kstars_workspace:/home/jenkins/workspace -v ccache:/home/jenkins/.ccache'
        }
    }
    
    parameters {
        string(name: 'REPO',   defaultValue: 'https://github.com/OpenPHDGuiding/phd2.git', description: 'The repository to clone from.')
        string(name: 'BRANCH', defaultValue: 'master', description: 'The repository branch to build.')
        string(name: 'TAG',    defaultValue: 'v2.6.8', description: 'The repository tag to build.')
    }

    environment {
        CFLAGS = '-m32'
        CXXFLAGS = '-m32'
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
                      "SET(CMAKE_SYSTEM_PROCESSOR i386)" \
                      "SET(CMAKE_C_COMPILER gcc)" \
                      "SET(CMAKE_C_FLAGS -m32)" \
                      "SET(CMAKE_CXX_COMPILER g++)" \
                      "SET(CMAKE_CXX_FLAGS -m32)" > ~/i386.cmake
                '''
            }
        }

        stage('Checkout') {
            steps {
                git url: "${params.REPO}",
                    branch: "${params.BRANCH}"
                sh "[ -z ${params.TAG} ] || git checkout ${params.TAG}"
            }
        }

        stage('Build') {
            steps {
                dir('phd2-build') {
                    deleteDir()
                    sh "cmake -DCMAKE_TOOLCHAIN_FILE=~/i386.cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCCACHE_SUPPORT=ON ${env.WORKSPACE}"
                    sh "make -j4 clean all"
                }
            }
        }

        stage('Test') {
            steps {
                catchError (message:'Test Failure', buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    dir('phd2-build') {
                        sh 'make test'
                    }
                }
            }
        }
        
        stage('Package') {
            steps {
                dir('phd2-build') {
                    sh '''
                        version=`grep PHDVERSION ../phd.h | grep -o \"[0-9\\.]*\"`
                        version_patch=`git show HEAD | head -1 | cut -d' ' -f2 | cut -b-8`
                        package_file_name=\"phd2-$version.$version_patch-Linux-i386\"
                        cpack --debug --verbose \
                            -G DEB \
                            -P kstars \
                            -R $version \
                            -D CPACK_INSTALL_CMAKE_PROJECTS=\".;phd2;ALL;/\" \
                            -D CPACK_PACKAGING_INSTALL_PREFIX=/usr/local \
                            -D CPACK_PACKAGE_FILE_NAME=\"$package_file_name\" \
                            -D CPACK_PACKAGE_DESCRIPTION_FILE=../.git/HEAD \
                            -D CPACK_CMAKE_GENERATOR=\"Unix Makefiles\" \
                            -D CPACK_INSTALL_COMMANDS=\"make install\" \
                            -D CPACK_PACKAGE_CONTACT=\"https://github.com/TallFurryMan/kstars-ci\" \
                            -D CPACK_PACKAGE_DESCRIPTION_SUMMARY=\"PHD2 i386\" \
                            -D CPACK_DEBIAN_PACKAGE_ARCHITECTURE=i386
                        dpkg --info \"$package_file_name.deb\"
                    '''
                    archiveArtifacts artifacts: 'phd2-*.deb',
                                     fingerprint: true
                    deleteDir()
                }
            }
        }
    }
}
