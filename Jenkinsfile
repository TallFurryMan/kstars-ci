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
        string(name: 'REPO',   defaultValue: 'https://invent.kde.org/edejouhanet/kstars.git', description: 'The repository to clone from.')
        string(name: 'BRANCH', defaultValue: 'master', description: 'The repository branch to build.')
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
            }
        }

        stage('Build') {
            steps {
                sh '''
                    rm -rf kstars-build
                    mkdir -p kstars-build
                    cd kstars-build
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
                        $WORKSPACE
                    make -j4 clean all
                '''
            }
        }

        stage('Test') {
            steps {
                warnError ('Test Failure') {
                    sh '''
                        mkdir -p kstars-build
                        cd kstars-build
                        ldd kstars || true
                        make test
                    '''
                }
            }
        }
        
        stage('Package') {
            steps {
                sh '''
                    cd kstars-build
                    version_major=`grep MAJOR_VERSION CMakeCache.txt | cut -d'=' -f2`
                    version_minor=`grep MINOR_VERSION CMakeCache.txt | cut -d'=' -f2`
                    version_patch=`cd ../kstars && git show HEAD | head -1 | cut -d' ' -f2 | cut -b-8`
                    version=\"$version_major.$version_minor.$version_patch\"
                    package_file_name=\"kstars-$version-Linux-i386\"
                    cpack --debug --verbose \
                        -G DEB \
                        -P kstars \
                        -R $version \
                        -D CPACK_INSTALL_CMAKE_PROJECTS=\".;kstars;ALL;/\" \
                        -D CPACK_PACKAGING_INSTALL_PREFIX=/usr/local \
                        -D CPACK_PACKAGE_FILE_NAME=\"$package_file_name\" \
                        -D CPACK_PACKAGE_DESCRIPTION_FILE=../.git/HEAD \
                        -D CPACK_CMAKE_GENERATOR=\"Unix Makefiles\" \
                        -D CPACK_INSTALL_COMMANDS=\"make install\" \
                        -D CPACK_PACKAGE_CONTACT=\"https://github.com/TallFurryMan/kstars-ci\" \
                        -D CPACK_PACKAGE_DESCRIPTION_SUMMARY=\"KStars i386\" \
                        -D CPACK_DEBIAN_PACKAGE_ARCHITECTURE=i386
                    dpkg --info \"$package_file_name.deb\" || true
                '''
                archiveArtifacts artifacts: 'kstars-build/*.deb',
                                 fingerprint: true
            }
        }
    }
}
