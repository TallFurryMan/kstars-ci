pipeline {
  
  environment {
    GIT_URL = credentials('indi-git-url')
    CCACHE_COMPRESS = '1'
    CMAKE_OPTIONS = '-DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCCACHE_SUPPORT=ON'
    INDI_WITH_FLAGS = 
      '-DWITH_AHP_XC=OFF ' +
      '-DWITH_APOGEE=OFF ' +
      '-DWITH_ARMADILLO=OFF ' +
      '-DWITH_ASICAM=ON ' +
      '-DWITH_ASTROLINK4=OFF ' +
      '-DWITH_ASTROMECHFOC=OFF ' +
      '-DWITH_ATIK=ON ' +
      '-DWITH_AVALON=OFF ' +
      '-DWITH_BEEFOCUS=OFF ' +
      '-DWITH_BRESSEREXOS2=OFF ' +
      '-DWITH_CAUX=OFF ' +
      '-DWITH_CLOUDWATCHER=OFF ' +
      '-DWITH_DREAMFOCUSER=OFF ' +
      '-DWITH_DSI=OFF ' +
      '-DWITH_DUINO=ON ' +
      '-DWITH_EQMOD=ON ' +
      '-DWITH_FFMV=OFF ' +
      '-DWITH_FISHCAMP=OFF ' +
      '-DWITH_FLI=OFF ' +
      '-DWITH_GIGE=OFF ' +
      '-DWITH_GPHOTO=ON ' +
      '-DWITH_GPSD=OFF ' +
      '-DWITH_GPSNMEA=OFF ' +
      '-DWITH_INOVAPLX=OFF ' +
      '-DWITH_LIMESDR=OFF ' +
      '-DWITH_MAXDOME=OFF ' +
      '-DWITH_MGEN=ON ' +
      '-DWITH_MI=OFF ' +
      '-DWITH_MOONDUINO=ON ' +
      '-DWITH_NEXDOME=OFF ' +
      '-DWITH_NIGHTSCAPE=OFF ' +
      '-DWITH_NUT=OFF ' +
      '-DWITH_ORION_SSG3=OFF ' +
      '-DWITH_PENTAX=OFF ' +
      '-DWITH_PLAYERONE=OFF ' +
      '-DWITH_QHY=OFF ' +
      '-DWITH_QSI=OFF ' +
      '-DWITH_RADIOSIM=OFF ' +
      '-DWITH_RPICAM=OFF ' +
      '-DWITH_RTKLIB=OFF ' +
      '-DWITH_SBIG=OFF ' +
      '-DWITH_SHELYAK=OFF ' +
      '-DWITH_SKYWALKER=OFF ' +
      '-DWITH_SPECTRACYBER=OFF ' +
      '-DWITH_STARBOOK=OFF ' +
      '-DWITH_STARBOOK_TEN=OFF ' +
      '-DWITH_SV305=OFF ' +
      '-DWITH_SX=OFF ' +
      '-DWITH_TALON6=OFF ' +
      '-DWITH_TOUPBASE=OFF ' +
      '-DWITH_WEBCAM=ON ' +
      '-DWITH_WEEWX_JSON=OFF'
  }
  
  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }
  
  parameters {
    persistentString(name: 'REPO', defaultValue: 'indi.git', description: 'The repository to clone from.')
    persistentString(name: 'BRANCH', defaultValue: 'master', description: 'The repository branch to build.')
    persistentString(name: 'TAG', defaultValue: '', description: 'The repository tag to build.')
    persistentString(name: 'REPO3P', defaultValue: 'indi-3rdparty.git', description: 'The 3rdparty repository to clone from.')
    persistentString(name: 'BRANCH3P', defaultValue: 'master', description: 'The repository branch to build.')
    persistentString(name: 'TAG3P', defaultValue: '', description: 'The repository tag to build.')
  }
  
  agent {
    dockerfile {
      filename 'Dockerfile'
      additionalBuildArgs '--pull'
      args '-v kstars_workspace:/home/jenkins/workspace -v ccache:/home/jenkins/.ccache --group-add sudo'
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
              "SET(CMAKE_SYSTEM_PROCESSOR x86_64)" \
              "SET(CMAKE_C_COMPILER gcc)" \
              "SET(CMAKE_C_FLAGS -march=silvermont)" \
              "SET(CMAKE_CXX_COMPILER g++)" \
              "SET(CMAKE_CXX_FLAGS -march=silvermont)" > ~/z8350.cmake
        '''
      }
    }
    
    stage('Checkout Core') {
      steps {
        checkout([
          $class: 'GitSCM',
          userRemoteConfigs: [[ url: "${GIT_URL}/${params.REPO}" ]],
          branches: [[ name: "${params.BRANCH}" ]],
          extensions: [[ $class: 'CloneOption', shallow: true, depth: 10, timeout: 60 ]],
        ])
        sh "if [ -n '${params.TAG}' -a '${params.BRANCH}' != '${params.TAG}' ] ; then git checkout '${params.TAG}' ; fi"
        sh "git log --oneline --decorate -10"
      }
    }
    
    stage('Build Core') {
      steps {
        dir('indi-build') {
          deleteDir()
          sh "cmake -DCMAKE_TOOLCHAIN_FILE=~/z8350.cmake ${env.CMAKE_OPTIONS} ${env.INDI_WITH_FLAGS} ${env.WORKSPACE}"
          sh "make -j4 all"
        }
      }
    }
    
    stage('Test Core') {
      steps {
        catchError (message:'Test Failure', buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
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
            indiapi="$(find "$WORKSPACE" -name indiapi.h)"
            version_major=`grep \'INDI_VERSION_MAJOR .*$\' "$indiapi" | head -1 | grep -o \'[0-9\\.]*\'`
            version_minor=`grep \'INDI_VERSION_MINOR .*$\' "$indiapi" | head -1 | grep -o \'[0-9\\.]*\'`
            version_revision=`grep \'INDI_VERSION_RELEASE .*$\' "$indiapi" | head -1 | grep -o \'[0-9\\.]*\'`
            version_patch=`git show HEAD | head -1 | cut -d\' \' -f2 | cut -b-8`
            version="$version_major.$version_minor.$version_revision-$version_patch"
            package_file_name="indi-core-$version-Linux-x86_64"
            cpack --debug --verbose -G DEB -P indi-core -R $version \
              -D CPACK_INSTALL_CMAKE_PROJECTS=".;indi;ALL;/" \
              -D CPACK_PACKAGING_INSTALL_PREFIX=/usr/local \
              -D CPACK_PACKAGE_FILE_NAME="$package_file_name" \
              -D CPACK_PACKAGE_DESCRIPTION_FILE=$WORKSPACE/.git/HEAD \
              -D CPACK_CMAKE_GENERATOR="Unix Makefiles" \
              -D CPACK_INSTALL_COMMANDS="make install" \
              -D CPACK_PACKAGE_CONTACT="https://github.com/TallFurryMan/kstars-ci" \
              -D CPACK_PACKAGE_DESCRIPTION_SUMMARY="INDI Core Z8350" \
              -D CPACK_DEBIAN_PACKAGE_ARCHITECTURE=amd64
            dpkg --info "$package_file_name.deb"
          '''
          archiveArtifacts(artifacts: 'indi-core-*.deb', fingerprint: true)
          sh 'id'
          sh 'sudo make install'
          deleteDir()
        }
      }
    }
    
    stage('Checkout 3rd-party') {
      steps {
        dir('3rdparty') {
          checkout([
            $class: 'GitSCM',
            userRemoteConfigs: [[ url: "${GIT_URL}/${params.REPO3P}" ]],
            branches: [[ name: "${params.BRANCH3P}" ]],
            extensions: [[ $class: 'CloneOption', shallow: true, depth: 10, timeout: 60 ]],
          ])
          sh "if [ -n '${params.TAG3P}' -a '${params.BRANCH3P}' != '${params.TAG3P}' ] ; then git checkout '${params.TAG3P}' ; fi"
          sh "git log --oneline --decorate -10"
        }
      }
    }
    
    stage('Build 3rd-party libraries') {
      steps {
        dir('indi3p-libs-build') {
          deleteDir()
          sh "cmake -DCMAKE_TOOLCHAIN_FILE=~/z8350.cmake ${env.CMAKE_OPTIONS} ${env.INDI_WITH_FLAGS} ${env.WORKSPACE}/3rdparty"
          sh "make -j4 all"
        }
      }
    }
    
    stage('Package libraries') {
      steps {
        dir('indi3p-libs-build') {
          sh '''
            indiapi="$(find "/usr/local/include/libindi" -name indiapi.h)"
            version_major=`grep \'INDI_VERSION_MAJOR .*$\' "$indiapi" | head -1 | grep -o \'[0-9\\.]*\'`
            version_minor=`grep \'INDI_VERSION_MINOR .*$\' "$indiapi" | head -1 | grep -o \'[0-9\\.]*\'`
            version_revision=`grep \'INDI_VERSION_RELEASE .*$\' "$indiapi" | head -1 | grep -o \'[0-9\\.]*\'`
            version_patch=`cd ../3rdparty && git show HEAD | head -1 | cut -d\' \' -f2 | cut -b-8`
            version="$version_major.$version_minor.$version_revision-$version_patch"
            package_file_name="indi-3rdparty-libs-$version-Linux-x86_64"
            cpack -G DEB -P indi-3rdparty-libs -R $version \
              -D CPACK_INSTALL_CMAKE_PROJECTS=".;indi-3rdparty-libs;ALL;/" \
              -D CPACK_PACKAGING_INSTALL_PREFIX=/usr/local \
              -D CPACK_PACKAGE_FILE_NAME="$package_file_name" \
              -D CPACK_PACKAGE_DESCRIPTION_FILE=$WORKSPACE/3rdparty/.git/HEAD \
              -D CPACK_CMAKE_GENERATOR="Unix Makefiles" \
              -D CPACK_INSTALL_COMMANDS="make install" \
              -D CPACK_PACKAGE_CONTACT="https://github.com/TallFurryMan/kstars-ci" \
              -D CPACK_PACKAGE_DESCRIPTION_SUMMARY="INDI 3rd-party Libraries Z8350" \
              -D CPACK_DEBIAN_PACKAGE_ARCHITECTURE=amd64
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
          sh "cmake -DCMAKE_TOOLCHAIN_FILE=~/z8350.cmake -DBUILD_LIBS=ON ${env.CMAKE_OPTIONS} ${env.INDI_WITH_FLAGS} ${env.WORKSPACE}/3rdparty"
          sh "make -j4 all"
          sh "cmake -DCMAKE_TOOLCHAIN_FILE=~/z8350.cmake -DBUILD_LIBS=OFF ${env.CMAKE_OPTIONS} ${env.INDI_WITH_FLAGS} ${env.WORKSPACE}/3rdparty"
          sh "make -j4 all"
        }
      }
    }
    
    stage('Test 3rd-party drivers') {
      steps {
        catchError (message:'Test Failure', buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
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
            indiapi="$(find "/usr/local/include/libindi" -name indiapi.h)"
            version_major=`grep \'INDI_VERSION_MAJOR .*$\' "$indiapi" | head -1 | grep -o \'[0-9\\.]*\'`
            version_minor=`grep \'INDI_VERSION_MINOR .*$\' "$indiapi" | head -1 | grep -o \'[0-9\\.]*\'`
            version_revision=`grep \'INDI_VERSION_RELEASE .*$\' "$indiapi" | head -1 | grep -o \'[0-9\\.]*\'`
            version_patch=`cd ../3rdparty && git show HEAD | head -1 | cut -d\' \' -f2 | cut -b-8`
            version="$version_major.$version_minor.$version_revision.$version_patch"
            package_file_name="indi-3rdparty-drivers-$version-Linux-x86_64"
            cpack --debug --verbose -G DEB -P indi-3rdparty-drivers -R $version \
              -D CPACK_INSTALL_CMAKE_PROJECTS=".;indi-3rdparty;ALL;/" \
              -D CPACK_PACKAGING_INSTALL_PREFIX=/usr/local \
              -D CPACK_PACKAGE_FILE_NAME="$package_file_name" \
              -D CPACK_PACKAGE_DESCRIPTION_FILE=$WORKSPACE/3rdparty/.git/HEAD \
              -D CPACK_CMAKE_GENERATOR="Unix Makefiles" \
              -D CPACK_INSTALL_COMMANDS="make install" \
              -D CPACK_PACKAGE_CONTACT="https://github.com/TallFurryMan/kstars-ci" \
              -D CPACK_PACKAGE_DESCRIPTION_SUMMARY="INDI 3rd-party Z8350" \
              -D CPACK_DEBIAN_PACKAGE_ARCHITECTURE=amd64
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
