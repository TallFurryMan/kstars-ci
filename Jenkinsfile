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
        string(name: 'REPO',   defaultValue: 'https://github.com/indilib/indi.git', description: 'The repository to clone from.')
        string(name: 'BRANCH', defaultValue: 'master', description: 'The repository branch to build.')
        string(name: 'TAG',    defaultValue: 'master', description: 'The repository tag to build.')
    }

    environment {
        CFLAGS = '-m32'
        CXXFLAGS = '-m32'
        CCACHE_COMPRESS = '1'
    }

    stages {
        
        stage('Preparation') {
            steps {
                sh '''
                    cat ~/built_on
                    [ -f ~/.ccache/ccache.conf ] || touch ~/.ccache/ccache.conf
                    ccache --max-size 20G
                    ccache -s
                '''
            }
        }

        stage('Checkout') {
            steps {
                git url: "${params.REPO}",
                    branch: "${params.BRANCH}"
                sh "git checkout ${params.TAG}"
            }
        }

        stage('Build') {
            steps {
                sh '''
                    rm -rf indi-build
                    mkdir -p indi-build
                    cd indi-build
                    printf \"%s\\n\" \
                        "SET(CMAKE_SYSTEM_NAME Linux)" \
                        "SET(CMAKE_SYSTEM_PROCESSOR i386)" \
                        "SET(CMAKE_C_COMPILER gcc)" \
                        "SET(CMAKE_C_FLAGS -m32)" \
                        "SET(CMAKE_CXX_COMPILER g++)" \
                        "SET(CMAKE_CXX_FLAGS -m32)" \
                        > i386.cmake
                    cat i386.cmake
                    cmake \
                        -DCMAKE_TOOLCHAIN_FILE=i386.cmake \
                        -DCMAKE_INSTALL_PREFIX=/usr/local \
                        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
                        -DCCACHE_SUPPORT=ON \
                        -DWITH_MI=OFF        -DWITH_FLI=OFF          -DWITH_SBIG=OFF         -DWITH_INOVAPLX=OFF \
                        -DWITH_APOGEE=OFF    -DWITH_FFMV=OFF         -DWITH_QHY=OFF          -DWITH_SSAG=OFF \
                        -DWITH_QSI=OFF       -DWITH_FISHCAMP=OFF     -DWITH_GPSD=OFF         -DWITH_DSI=OFF \
                        -DWITH_ASICAM=ON     -DWITH_ASTROMECHFOC=OFF -DWITH_LIMESDR=OFF \
                        -DWITH_RTLSDR=OFF    -DWITH_RADIOSIM=OFF     -DWITH_GPSNMEA=OFF \
                        -DWITH_ARMADILLO=OFF -DWITH_NIGHTSCAPE=OFF   -DWITH_ATIK=ON \
                        -DWITH_TOUPBASE=OFF  -DWITH_ALTAIRCAM=OFF    -DWITH_DREAMFOCUSER=OFF \
                        -DWITH_AVALON=OFF    -DWITH_BEEFOCUS=OFF     -DWITH_WEBCAM=OFF \
                        $WORKSPACE
                    make -j4 clean all
                '''
            }
        }

        stage('Test') {
            steps {
                warnError ('Test Failure') {
                    sh '''
                        mkdir -p indi-build
                        cd indi-build
                        make test
                    '''
                }
            }
        }
        
        stage('Package') {
            steps {
                sh '''
                    cd indi-build
                    version_major=`grep 'INDI_VERSION_MAJOR .*$' ../indiapi.h | head -1 | grep -o '[0-9\\.]*'`
                    version_minor=`grep 'INDI_VERSION_MINOR .*$' ../indiapi.h | head -1 | grep -o '[0-9\\.]*'`
                    version_revision=`grep 'INDI_VERSION_RELEASE .*$' ../indiapi.h | head -1 | grep -o '[0-9\\.]*'`
                    version_patch=`git show HEAD | head -1 | cut -d' ' -f2 | cut -b-8`
                    version=\"$version_major.$version_minor.$version_revision.$version_patch\"
                    package_file_name=\"kstars-$version-Linux-i386\"
                    cpack --debug --verbose \
                        -G DEB \
                        -P kstars \
                        -R $version \
                        -D CPACK_INSTALL_CMAKE_PROJECTS=\".;indi;ALL;/\" \
                        -D CPACK_PACKAGING_INSTALL_PREFIX=/usr/local \
                        -D CPACK_PACKAGE_FILE_NAME=\"$package_file_name\" \
                        -D CPACK_PACKAGE_DESCRIPTION_FILE=../.git/HEAD \
                        -D CPACK_CMAKE_GENERATOR=\"Unix Makefiles\" \
                        -D CPACK_INSTALL_COMMANDS=\"make install\" \
                        -D CPACK_PACKAGE_CONTACT=\"https://github.com/TallFurryMan/kstars-ci\" \
                        -D CPACK_PACKAGE_DESCRIPTION_SUMMARY=\"INDI Core i386\" \
                        -D CPACK_DEBIAN_PACKAGE_ARCHITECTURE=i386
                    dpkg --info \"$package_file_name.deb\" || true
                '''
                archiveArtifacts artifacts: 'indi-build/*.deb',
                                 fingerprint: true
            }
        }
    }
}
