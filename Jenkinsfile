pipeline {
  
  environment {
    CCACHE_COMPRESS = '1'
  }
  
  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }
  
  parameters {
    string(name: 'REPO', defaultValue: 'https://github.com/rlancaste/stellarsolver.git', description: 'The repository to clone from.')
    string(name: 'BRANCH', defaultValue: 'master', description: 'The repository branch to build.')
    string(name: 'TAG', defaultValue: 'master', description: 'The repository tag to build.')
  }
  
  agent {
    dockerfile {
      filename 'Dockerfile'
      additionalBuildArgs '--pull'
      args '-v stellarsolver_workspace:/home/jenkins/workspace -v ccache:/home/jenkins/.ccache'
    }
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
        
    stage('Dependencies') {
      steps {
        script {
          dir('stellarsolver-deps') {
            echo 'No dependency'
            deleteDir()
          }
        }
      }
    }
    
    stage('Checkout') {
      steps {
        git(url: "${params.REPO}", branch: "${params.BRANCH}")
        sh "git checkout ${params.TAG}"
        sh "git log --oneline --decorate -10"
      }
    }
    
    stage('Build') {
      steps {
        dir('stellarsolver-build') {
          deleteDir()
          sh '''
            printf "%s\\n" \
              "SET(CMAKE_SYSTEM_NAME Linux)" \
              "SET(CMAKE_SYSTEM_PROCESSOR x86_64)" \
              "SET(CMAKE_C_COMPILER gcc)" \
              "SET(CMAKE_C_FLAGS -march=silvermont)" \
              "SET(CMAKE_CXX_COMPILER g++)" \
              "SET(CMAKE_CXX_FLAGS -march=silvermont)" > z8350.cmake
            cmake \
              -DCMAKE_TOOLCHAIN_FILE=z8350.cmake \
              -DCMAKE_INSTALL_PREFIX=/usr/local \
              -DCMAKE_BUILD_TYPE=RelWithDebInfo \
              -DBUILD_TESTER=OFF \
              -DCCACHE_SUPPORT=ON \
              -DRUN_RESULT_2=0 -DRUN_RESULT_3=0 -DRUN_RESULT_4=0 \
              $WORKSPACE
            make -j4 clean all
          '''
        }
      }
    }
    
    stage('Test') {
      steps {
        catchError (message:'Test Failure', buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
          dir('stellarsolver-build') {
            sh 'make test'
          }
        }
      }
    }
    
    stage('Package') {
      steps {
        dir('stellarsolver-build') {
          sh '''
            version=`grep \'(StellarSolver_VERSION_MAJOR .*)$\' ../CMakeLists.txt | head -1 | grep -o \'[0-9\\.]*\'`
            version="$version."`grep \'(StellarSolver_VERSION_MINOR .*)$\' ../CMakeLists.txt | head -1 | grep -o \'[0-9\\.]*\'`
            version_patch=`git show HEAD | head -1 | cut -d\' \' -f2 | cut -b-8`
            package_file_name="stellarsolver-$version-$version_patch-Linux-x86_64"
            cpack -G DEB -P stellarsolver -R $version \
              -D CPACK_INSTALL_CMAKE_PROJECTS=".;stellarsolver;ALL;/" \
              -D CPACK_PACKAGING_INSTALL_PREFIX=/usr/local \
              -D CPACK_PACKAGE_FILE_NAME="$package_file_name" \
              -D CPACK_PACKAGE_DESCRIPTION_FILE=../.git/HEAD \
              -D CPACK_CMAKE_GENERATOR="Unix Makefiles" \
              -D CPACK_INSTALL_COMMANDS="make install" \
              -D CPACK_PACKAGE_CONTACT="https://github.com/TallFurryMan/kstars-ci" \
              -D CPACK_PACKAGE_DESCRIPTION_SUMMARY="StellarSolver Z8350" \
              -D CPACK_DEBIAN_PACKAGE_ARCHITECTURE=amd64
            dpkg --info "$package_file_name.deb" || true
          '''
          archiveArtifacts(artifacts: 'stellarsolver-*.deb', fingerprint: true)
          deleteDir()
        }
      }
    }
  }
}
