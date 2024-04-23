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
        persistentString(name: 'REPO',   defaultValue: env.PHD2_GIT ?: 'https://github.com/OpenPHDGuiding/phd2.git', description: 'The repository to clone from, by default https://github.com/OpenPHDGuiding/phd2.git.')
        persistentString(name: 'BRANCH', defaultValue: 'master', description: 'The repository branch to build.')
        persistentString(name: 'TAG',    defaultValue: 'v2.6.9', description: 'The repository tag to build.')
        buildSelector(name: 'INDI_CORE_BUILD', defaultSelector: lastSuccessful(), description: 'The build to use for INDI Core, empty for last successful build.')
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
                      "SET(CMAKE_C_FLAGS -march=silvermont)" \
                      "SET(CMAKE_CXX_COMPILER g++)" \
                      "SET(CMAKE_CXX_FLAGS -march=silvermont)" > ~/z8350.cmake
                '''
            }
        }

        stage('Dependencies') {
            steps {
                script {
                    dir('kstars-deps') {
                       sh "sleep 30"
                       sh "rm -f ./indi-*-x86_64.deb"
                       copyArtifacts projectName: 'kstars-ci/atom-indi',
                         filter: '*.deb',
                         selector: params.INDI_CORE_BUILD ? buildParameter('INDI_CORE_BUILD') : lastSuccessful(),
                         target: '.',
                         fingerprintArtifacts: true
                       sh "sudo dpkg --install --force-overwrite ./indi-*-x86_64.deb"
                       deleteDir()
                    }
                }
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
                // https://github.com/OpenPHDGuiding/phd2/pull/975/files
                sh "sed -i 's/libwxgtk3.0-0v5/libwxgtk3.0-0v5 | libwxgtk3.0-gtk3-0v5/' cmake_modules/PHD2Packaging.cmake"
                dir('phd2-build') {
                    deleteDir()
                    sh "cmake -DCMAKE_TOOLCHAIN_FILE=~/z8350.cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCCACHE_SUPPORT=ON ${env.WORKSPACE}"
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
                        package_file_name=\"phd2-$version.$version_patch-Linux-x86_64\"
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
                            -D CPACK_PACKAGE_DESCRIPTION_SUMMARY=\"PHD2 Z8350\" \
                            -D CPACK_DEBIAN_PACKAGE_ARCHITECTURE=amd64
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
