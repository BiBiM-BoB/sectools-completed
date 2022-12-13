stage('dependency-check') {
  sh components_dir + "SCA/dependency-check/script/run.sh ${env.WORKSPACE}"
}