pipeline {
  
  environment {
    CCACHE_COMPRESS = '1'
  }
  
  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }
  
  parameters {
    persistentString(name: 'REPO', defaultValue: 'https://github.com/rlancaste/stellarsolver.git', description: 'The repository to clone from.')
    persistentString(name: 'BRANCH', defaultValue: 'master', description: 'The repository branch to build.')
    persistentString(name: 'TAG', defaultValue: 'master', description: 'The repository tag to build.')
    persistentBoolean(name: 'COVERITY', defaultValue: false, description: 'Whether to run and push a static analysis to Coverity Scan.')
  }
  
  agent {
    dockerfile {
      filename 'Dockerfile'
      additionalBuildArgs '--pull'
      args '-v stellarsolver_workspace:/home/jenkins/workspace -v ccache:/home/jenkins/.ccache -v coverity_volume:/mnt'
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
        checkout([
          $class: 'GitSCM',
          userRemoteConfigs: [[ url: "${params.REPO}" ]],
          branches: [[ name: "${params.BRANCH}" ]],
          extensions: [[ $class: 'CloneOption', shallow: true, depth: 1, timeout: 60 ]],
        ])
        sh "if [ -n '${params.TAG}' -a '${params.BRANCH}' != '${params.TAG}' ] ; then git checkout '${params.TAG}' ; fi"
        sh "git log --oneline --decorate -10"
        script {
          VERSION = sh( script: '''
              version=`grep \'(StellarSolver_VERSION_MAJOR .*)$\' ./CMakeLists.txt | head -1 | grep -o \'[0-9\\.]*\'`
              version="$version."`grep \'(StellarSolver_VERSION_MINOR .*)$\' ./CMakeLists.txt | head -1 | grep -o \'[0-9\\.]*\'`
              version_patch=`git show HEAD | head -1 | cut -d\' \' -f2 | cut -b-8`
              echo "$version-$version_patch"
              ''',
              returnStdout: true).trim()
        }
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
              "SET(CMAKE_C_FLAGS -march=x86-64)" \
              "SET(CMAKE_CXX_COMPILER g++)" \
              "SET(CMAKE_CXX_FLAGS -march=x86-64)" > amd64.cmake
            cmake \
              -DCMAKE_TOOLCHAIN_FILE=amd64.cmake \
              -DCMAKE_INSTALL_PREFIX=/usr/local \
              -DCMAKE_BUILD_TYPE=RelWithDebInfo \
              -DBUILD_TESTER=OFF \
              -DCCACHE_SUPPORT=ON \
              -DRUN_RESULT_2=0 -DRUN_RESULT_3=0 -DRUN_RESULT_4=0 \
              $WORKSPACE
            make -j4 clean all
          '''
          recordIssues(tools: [gcc()]) // Requires Warnings-NG
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
    
    stage('Coverity') {
      when {
        expression { params.COVERITY }
      }
      environment {
        PATH='/mnt/cov-analysis/bin:${env.PATH}'
      }
      steps {
        catchError (message:'Test Failure', buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
          dir('coverity-build') {
            sh 'cmake -B. -H.. -DCCACHE_SUPPORT=OFF -DUNITY_BUILD=OFF -DCMAKE_BUILD_TYPE=Debug'
            sh 'PATH="/mnt/cov-analysis/bin:$PATH" cov-build --dir ./cov-int make -j2 -C .'
            sh 'tar czvf ../stellarsolver-cov-build.tgz ./cov-int'
            deleteDir()
          }
          script {
            try {
              withCredentials([usernamePassword(credentialsId: 'coverity-stellarsolver-token', usernameVariable: 'EMAIL', passwordVariable: 'TOKEN')]) {
                httpRequest consoleLogResponseBody: true,
                  formData: [
                    [body: '$TOKEN', contentType: '', fileName: '', name: 'token', uploadFile: ''],
                    [body: '$EMAIL', contentType: '', fileName: '', name: 'email', uploadFile: ''],
                    [body: '${env.VERSION}', contentType: '', fileName: '', name: 'version', uploadFile: ''],
                    [body: 'Jenkins CI Upload', contentType: '', fileName: '', name: 'description', uploadFile: ''],
                    [body: '', contentType: '', fileName: '', name: 'file', uploadFile: 'stellarsolver-cov-build.tgz']],
                  httpMode: 'POST',
                  url: 'https://scan.coverity.com/builds?project=TallFurryMan%2Fstellarsolver'
              }
            } catch(e) {
              withCredentials([usernamePassword(credentialsId: 'coverity-stellarsolver-token', usernameVariable: 'EMAIL', passwordVariable: 'TOKEN')]) {
                sh '''
                curl \
                  --form token="$TOKEN" \
                  --form email="$EMAIL" \
                  --form file=@stellarsolver-cov-build.tgz \
                  --form version="$VERSION" \
                  --form description="Jenkins CI Upload" \
                  https://scan.coverity.com/builds?project=TallFurryMan%2Fstellarsolver
                '''
              }
            }
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
              -D CPACK_PACKAGE_DESCRIPTION_SUMMARY="StellarSolver amd64" \
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
