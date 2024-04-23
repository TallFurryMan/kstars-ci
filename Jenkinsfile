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
    persistentString(name: 'REPO', defaultValue: 'https://invent.kde.org/education/kstars.git', description: 'The repository to clone from. E.g. https://invent.kde.org/education/kstars.git or git@invent.kde.org:education/kstars.git.')
    persistentString(name: 'BRANCH', defaultValue: 'master', description: 'The repository branch to build. Use tags/<a_tag> to check tag a_tag out.')
    //string(name: 'TAG', defaultValue: '', description: 'The repository tag to build.')
    buildSelector(name: 'INDI_CORE_BUILD', defaultSelector: lastSuccessful(), description: 'The build to use for INDI Core, empty for last successful build.')
    buildSelector(name: 'STELLARSOLVER_BUILD', defaultSelector: lastSuccessful(), description: 'The build to use for StellarSolver, empty for last successful build.')
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
          sh '''
            cat ~/built_on
            [ -f ~/.ccache/ccache.conf ] || touch ~/.ccache/ccache.conf
            ccache --max-size 20G
            ccache -s
          '''
          buildName "${BRANCH}"
          buildDescription "${BRANCH}"
        }
    }
        
    stage('Dependencies') {
      steps {
        script {
          dir('kstars-deps') {
            sh "sleep 30"
            sh "rm -f ./indi-*-i386.deb ./stellarsolver-*-i386.deb"
            copyArtifacts projectName: 'kstars-ci/i386-indi',
              filter: '*.deb',
              selector: buildParameter('INDI_CORE_BUILD'),
              target: '.',
              fingerprintArtifacts: true
            copyArtifacts projectName: 'kstars-ci/i386-stellarsolver',
              filter: '*.deb',
              selector: buildParameter('STELLARSOLVER_BUILD'),
              target: '.',
              fingerprintArtifacts: true
            sh "sudo dpkg --install --force-overwrite ./indi-*-i386.deb ./stellarsolver-*-i386.deb"
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
              -DBUILD_TESTING=OFF \
              $WORKSPACE
            make -j3 clean all
          '''
        }
      }
    }
    
    //stage('Test') {
    //  steps {
    //    catchError (message:'Test Failure', buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
    //      dir('kstars-build') {
    //        sh 'make test'
    //      }
    //    }
    //  }
    //}
    
    stage('Package') {
      steps {
        dir('kstars-build') {
          sh '''
            version=`grep \'KSTARS_VERSION .*$\' kstars/version.h | head -1 | grep -o \'[0-9\\.]*\'`
            version_patch=`git show HEAD | head -1 | cut -d\' \' -f2 | cut -b-8`
            package_file_name="kstars-$version-$version_patch-Linux-i386"
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
