pipeline {
  environment {
    CFLAGS = '-m32'
    CXXFLAGS = '-m32'
    CCACHE_COMPRESS = '1'
    CMAKE_OPTIONS = '-DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCCACHE_SUPPORT=ON'
    INDI_WITH_FLAGS = 
      '-DWITH_EQMOD=ON ' +
      '-DWITH_STARBOOK=OFF ' +
      '-DWITH_NSE=OFF ' +
      '-DWITH_CAUX=OFF ' +
      '-DWITH_SX=OFF ' +
      '-DWITH_MAXDOME=OFF ' +
      '-DWITH_NEXDOME=OFF ' +
      '-DWITH_SPECTRACYBER=OFF ' +
      '-DWITH_MI=OFF ' +
      '-DWITH_FLI=OFF ' +
      '-DWITH_SBIG=OFF ' +
      '-DWITH_INOVAPLX=OFF ' +
      '-DWITH_APOGEE=OFF ' +
      '-DWITH_FFMV=OFF ' +
      '-DWITH_QHY=OFF ' +
      '-DWITH_GPHOTO=ON ' +
      '-DWITH_QSI=OFF ' +
      '-DWITH_DUINO=ON ' +
      '-DWITH_FISHCAMP=OFF ' +
      '-DWITH_GPSD=OFF ' +
      '-DWITH_GIGE=OFF ' +
      '-DWITH_DSI=OFF ' +
      '-DWITH_ASICAM=ON ' +
      '-DWITH_MGEN=ON ' +
      '-DWITH_ASTROMECHFOC=OFF ' +
      '-DWITH_LIMESDR=OFF ' +
      '-DWITH_RTLSDR=OFF ' +
      '-DWITH_RADIOSIM=OFF ' +
      '-DWITH_GPSNMEA=OFF ' +
      '-DWITH_RTKLIB=OFF ' +
      '-DWITH_ARMADILLO=OFF ' +
      '-DWITH_FXLOAD=OFF ' +
      '-DWITH_NIGHTSCAPE=OFF ' +
      '-DWITH_ATIK=ON ' +
      '-DWITH_TOUPBASE=OFF ' +
      '-DWITH_ALTAIRCAM=OFF ' +
      '-DWITH_DREAMFOCUSER=OFF ' +
      '-DWITH_AVALON=OFF ' +
      '-DWITH_BEEFOCUS=OFF ' +
      '-DWITH_SHELYAK=OFF ' +
      '-DWITH_SKYWALKER=OFF ' +
      '-DWITH_TALON6=OFF ' +
      '-DWITH_PENTAX=OFF ' +
      '-DWITH_ASTROLINK4=OFF ' +
      '-DWITH_AHP_INTERFEROMETER=OFF ' +
      '-DWITH_SV305=OFF ' +
      '-DWITH_WEBCAM=OFF'
  }
  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }
  parameters {
    string(name: 'REPO', defaultValue: 'https://github.com/indilib/indi.git', description: 'The repository to clone from.')
    string(name: 'BRANCH', defaultValue: 'master', description: 'The repository branch to build.')
    string(name: 'TAG', defaultValue: 'master', description: 'The repository tag to build.')
    string(name: 'REPO3P', defaultValue: 'https://github.com/indilib/indi-3rdparty.git', description: 'The 3rdparty repository to clone from.')
    string(name: 'BRANCH3P', defaultValue: 'master', description: 'The repository branch to build.')
    string(name: 'TAG3P', defaultValue: 'master', description: 'The repository tag to build.')
  }
  agent {
    dockerfile {
      filename 'Dockerfile'
      args '-v kstars_workspace:/home/jenkins/workspace -v ccache:/home/jenkins/.ccache'
    }
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
    stage('Checkout Core') {
      steps {
        git(url: "${params.REPO}", branch: "${params.BRANCH}")
        sh "git checkout ${params.TAG}"
        dir('3rdparty') {
          git(url: "${params.REPO3P}", branch: "${params.BRANCH3P}")
          sh "git checkout ${params.TAG3P}"
        }
      }
    }
    stage('Build Core') {
      steps {
        dir('indi-build') {
          deleteDir()
          sh "cmake -DCMAKE_TOOLCHAIN_FILE=~/i386.cmake ${env.CMAKE_OPTIONS} ${env.INDI_WITH_FLAGS} ${env.WORKSPACE}"
          sh "make -j4 all"
        }
      }
    }
    stage('Test Core') {
      steps {
        warnError(message: 'Test Failure', buildResult: 'SUCCESS') {
          dir('indi-build') {
            sh 'make test'
          }
        }
      }
    }
    stage('Package Core') {
      steps {
        dir('indi-build') {
          sh '''
            version_major=`grep \'INDI_VERSION_MAJOR .*$\' ../indiapi.h | head -1 | grep -o \'[0-9\\.]*\'`
            version_minor=`grep \'INDI_VERSION_MINOR .*$\' ../indiapi.h | head -1 | grep -o \'[0-9\\.]*\'`
            version_revision=`grep \'INDI_VERSION_RELEASE .*$\' ../indiapi.h | head -1 | grep -o \'[0-9\\.]*\'`
            version_patch=`git show HEAD | head -1 | cut -d\' \' -f2 | cut -b-8`
            version="$version_major.$version_minor.$version_revision.$version_patch"
            package_file_name="indi-core-$version-Linux-i386"
            cpack --debug --verbose -G DEB -P indi-core -R $version \
              -D CPACK_INSTALL_CMAKE_PROJECTS=".;indi;ALL;/" \
              -D CPACK_PACKAGING_INSTALL_PREFIX=/usr/local \
              -D CPACK_PACKAGE_FILE_NAME="$package_file_name" \
              -D CPACK_PACKAGE_DESCRIPTION_FILE=$WORKSPACE/.git/HEAD \
              -D CPACK_CMAKE_GENERATOR="Unix Makefiles" \
              -D CPACK_INSTALL_COMMANDS="make install" \
              -D CPACK_PACKAGE_CONTACT="https://github.com/TallFurryMan/kstars-ci" \
              -D CPACK_PACKAGE_DESCRIPTION_SUMMARY="INDI Core i386" \
              -D CPACK_DEBIAN_PACKAGE_ARCHITECTURE=i386
            dpkg --info "$package_file_name.deb"
          '''
          archiveArtifacts(artifacts: 'indi-core-*.deb', fingerprint: true)
          sh 'sudo make install'
          deleteDir()
        }
      }
    }
    stage('Checkout 3rd-party') {
      steps {
        dir('3rdparty') {
          git(url: "${params.REPO3P}", branch: "${params.BRANCH3P}")
          sh "git checkout ${params.TAG3P}"
        }
      }
    }
    stage('Build 3rd-party libraries') {
      steps {
        dir('indi3p-libs-build') {
          deleteDir()
          sh "cmake -DCMAKE_TOOLCHAIN_FILE=~/i386.cmake ${env.CMAKE_OPTIONS} ${env.INDI_WITH_FLAGS} ${env.WORKSPACE}/3rdparty"
          sh "make -j4 all"
        }
      }
    }
    stage('Package libraries') {
      steps {
        dir('indi3p-libs-build') {
          sh '''
            version_major=`grep \'INDI_VERSION_MAJOR .*$\' ../indiapi.h | head -1 | grep -o \'[0-9\\.]*\'`
            version_minor=`grep \'INDI_VERSION_MINOR .*$\' ../indiapi.h | head -1 | grep -o \'[0-9\\.]*\'`
            version_revision=`grep \'INDI_VERSION_RELEASE .*$\' ../indiapi.h | head -1 | grep -o \'[0-9\\.]*\'`
            version_patch=`cd ../3rdparty && git show HEAD | head -1 | cut -d\' \' -f2 | cut -b-8`
            version="$version_major.$version_minor.$version_revision.$version_patch"
            package_file_name="indi-3rdparty-libs-$version-Linux-i386"
            cpack -G DEB -P indi-3rdparty-libs -R $version \
              -D CPACK_INSTALL_CMAKE_PROJECTS=".;indi-3rdparty-libs;ALL;/" \
              -D CPACK_PACKAGING_INSTALL_PREFIX=/usr/local \
              -D CPACK_PACKAGE_FILE_NAME="$package_file_name" \
              -D CPACK_PACKAGE_DESCRIPTION_FILE=$WORKSPACE/3rdparty/.git/HEAD \
              -D CPACK_CMAKE_GENERATOR="Unix Makefiles" \
              -D CPACK_INSTALL_COMMANDS="make install" \
              -D CPACK_PACKAGE_CONTACT="https://github.com/TallFurryMan/kstars-ci" \
              -D CPACK_PACKAGE_DESCRIPTION_SUMMARY="INDI 3rd-party Libraries i386" \
              -D CPACK_DEBIAN_PACKAGE_ARCHITECTURE=i386
            dpkg --info "$package_file_name.deb"
          '''
          archiveArtifacts(artifacts: 'indi-3rdparty-libs-*.deb', fingerprint: true)
          sh 'sudo make install'
          deleteDir()
        }
      }
      post {
        failure {
          sh 'cat `find . -name InstallOutput.log`'
        }
      }
    }
    stage('Build 3rd-party drivers') {
      steps {
        dir('indi3p-build') {
          deleteDir()
          sh "cmake -DCMAKE_TOOLCHAIN_FILE=~/i386.cmake -DBUILD_LIBS=ON ${env.CMAKE_OPTIONS} ${env.INDI_WITH_FLAGS} ${env.WORKSPACE}/3rdparty"
          sh "make -j4 all"
          sh "cmake -DCMAKE_TOOLCHAIN_FILE=~/i386.cmake -DBUILD_LIBS=OFF ${env.CMAKE_OPTIONS} ${env.INDI_WITH_FLAGS} ${env.WORKSPACE}/3rdparty"
          sh "make -j4 all"
        }
      }
    }
    stage('Test 3rd-party drivers') {
      steps {
        warnError(message: 'Test Failure', buildResult: 'SUCCESS') {
          dir('indi3p-build') {
            sh 'make test'
          }
        }
      }
    }
    stage('Package') {
      steps {
        dir('indi3p-build') {
          sh '''
            version_major=`grep \'INDI_VERSION_MAJOR .*$\' ../indiapi.h | head -1 | grep -o \'[0-9\\.]*\'`
            version_minor=`grep \'INDI_VERSION_MINOR .*$\' ../indiapi.h | head -1 | grep -o \'[0-9\\.]*\'`
            version_revision=`grep \'INDI_VERSION_RELEASE .*$\' ../indiapi.h | head -1 | grep -o \'[0-9\\.]*\'`
            version_patch=`cd ../3rdparty && git show HEAD | head -1 | cut -d\' \' -f2 | cut -b-8`
            version="$version_major.$version_minor.$version_revision.$version_patch"
            package_file_name="indi-3rdparty-drivers-$version-Linux-i386"
            cpack --debug --verbose -G DEB -P indi-3rdparty-drivers -R $version \
              -D CPACK_INSTALL_CMAKE_PROJECTS=".;indi-3rdparty;ALL;/" \
              -D CPACK_PACKAGING_INSTALL_PREFIX=/usr/local \
              -D CPACK_PACKAGE_FILE_NAME="$package_file_name" \
              -D CPACK_PACKAGE_DESCRIPTION_FILE=$WORKSPACE/3rdparty/.git/HEAD \
              -D CPACK_CMAKE_GENERATOR="Unix Makefiles" \
              -D CPACK_INSTALL_COMMANDS="make install" \
              -D CPACK_PACKAGE_CONTACT="https://github.com/TallFurryMan/kstars-ci" \
              -D CPACK_PACKAGE_DESCRIPTION_SUMMARY="INDI 3rd-party i386" \
              -D CPACK_DEBIAN_PACKAGE_ARCHITECTURE=i386
            dpkg --info "$package_file_name.deb"
          '''
          archiveArtifacts(artifacts: 'indi-3rdparty-drivers-*.deb', fingerprint: true)
          deleteDir()
        }
      }
      post {
        failure {
          sh 'cat `find . -name InstallOutput.log`'
        }
      }
    }
  }
}
