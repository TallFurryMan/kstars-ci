pipeline {
    
    agent {
        dockerfile {
            filename 'Dockerfile'
            args '-v kstars_workspace:/home/jenkins/workspace -v ccache:/home/jenkins/.ccache'
        }
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
                sh 'ccache --max-size 20G'
                sh 'ccache -s'
            }
        }

        stage('Checkout') {
            steps {
                git url: 'https://invent.kde.org/edejouhanet/kstars.git',
                    branch: 'improve__phd2_fault_tolerance'
            }
        }

        stage('Build') {
            steps {
                sh '''
                    rm -rf kstars-build
                    mkdir -p kstars-build
                    cd kstars-build
                    printf "%s\n" \
                        "SET(CMAKE_SYSTEM_NAME Linux)" \
                        "SET(CMAKE_SYSTEM_PROCESSOR i386)" \
                        "SET(CMAKE_C_COMPILER gcc)" \
                        "SET(CMAKE_C_FLAGS -m32)" \
                        "SET(CMAKE_CXX_COMPILER g++)" \
                        "SET(CMAKE_CXX_FLAGS -m32)" \
                        > i386.make
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
                sh '''
                    mkdir -p kstars-build
                    cd kstars-build
                    file kstars | grep '32-bit'
                    make test
                '''
            }
        }
    }
}
