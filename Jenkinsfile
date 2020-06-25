pipeline {
    
    agent {
        dockerfile true
        args '-v kstars_workspace:/home/jenkins/workspace'
    }

    environment {
        CFLAGS = '-m32'
        CXXFLAGS = '-m32'
    }

    stages {
        
        stage('Preparation') {
            steps {
                sh 'cat ~/built_on'
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
                    echo "SET(CMAKE_SYSTEM_NAME Linux)" > i386.cmake
                    echo "SET(CMAKE_SYSTEM_PROCESSOR i386)" >> i386.cmake
                    echo "SET(CMAKE_C_COMPILER gcc)" >> i386.cmake
                    echo "SET(CMAKE_C_FLAGS -m32)" >> i386.cmake
                    echo "SET(CMAKE_CXX_COMPILER g++)" >> i386.cmake
                    echo "SET(CMAKE_CXX_FLAGS -m32)" >> i386.cmake
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
                    make install
                    file `which kstars` | grep '32-bit'
                '''
            }
        }
    }
}
