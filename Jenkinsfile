pipeline {
  environment {
    CFLAGS = '-m32'
    CXXFLAGS = '-m32'
    CCACHE_COMPRESS = '1'
  }
  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }
  parameters {
    string(name: 'REPO', defaultValue: 'https://invent.kde.org/edejouhanet/kstars.git', description: 'The repository to clone from.')
    string(name: 'BRANCH', defaultValue: 'master', description: 'The repository branch to build.')
    string(name: 'TAG', defaultValue: 'master', description: 'The repository tag to build.')
  }
  agent {
    dockerfile {
      filename 'Dockerfile'
      args '-v kstars_workspace:/home/jenkins/workspace -v ccache:/home/jenkins/.ccache'
    }
  }
  stages {
    stage('Preparation') {
      parallel {
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
        stage('Indi Core') {
          steps {
            copyArtifacts projectName: 'kstars-ci/i386-indi',
                          filter: '**/*.deb',
                          selector: lastSuccessful(),
                          fingerprintArtifacts: true
            sh 'sudo apt install -y --no-install-recommends `find . -name \'indi-*-Linux-i386.deb\'`'
          }
        }
      }
    }
    stage('Checkout') {
      steps {
        git(url: "${params.REPO}", branch: "${params.BRANCH}")
        sh "git checkout ${params.TAG}"
      }
    }
    stage('Build') {
      steps {
        dir('kstars-build') {
          deleteDir()
          sh '''
            printf "%s\\n" \
              "SET(CMAKE_SYSTEM_NAME Linux)" \
              "SET(CMAKE_SYSTEM_PROCESSOR i386)" \
              "SET(CMAKE_C_COMPILER gcc)" \
              "SET(CMAKE_C_FLAGS -m32)" \
              "SET(CMAKE_CXX_COMPILER g++)" \
              "SET(CMAKE_CXX_FLAGS -m32)" > i386.cmake
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
    }
    stage('Test') {
      steps {
        warnError(message: 'Test Failure') {
          dir('kstars-build') {
            sh 'make test'
          }
        }
      }
    }
    stage('Package') {
      steps {
        dir('kstars-build') {
          sh '''
            version=`grep \'KSTARS_VERSION .*$\' kstars/version.h | head -1 | grep -o \'[0-9\\.]*\'`
            version_patch=`git show HEAD | head -1 | cut -d\' \' -f2 | cut -b-8`
            package_file_name="kstars-$version.$version_patch-Linux-i386"
            cpack -G DEB -P kstars -R $version \
              -D CPACK_INSTALL_CMAKE_PROJECTS=".;kstars;ALL;/" \
              -D CPACK_PACKAGING_INSTALL_PREFIX=/usr/local \
              -D CPACK_PACKAGE_FILE_NAME="$package_file_name" \
              -D CPACK_PACKAGE_DESCRIPTION_FILE=../.git/HEAD \
              -D CPACK_CMAKE_GENERATOR="Unix Makefiles" \
              -D CPACK_INSTALL_COMMANDS="make install" \
              -D CPACK_PACKAGE_CONTACT="https://github.com/TallFurryMan/kstars-ci" \
              -D CPACK_PACKAGE_DESCRIPTION_SUMMARY="KStars i386" \
              -D CPACK_DEBIAN_PACKAGE_ARCHITECTURE=i386
            dpkg --info "$package_file_name.deb" || true
          '''
          archiveArtifacts(artifacts: 'kstars-*.deb', fingerprint: true)
          deleteDir()
        }
      }
    }
  }
}
