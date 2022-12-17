stage('dependency-check') {
  def dependency_check_dir = 'SCA/dependency-check/script/run.sh'
  sh 'chmod +x ' + components_dir + dependency_check_dir
  sh components_dir + dependency_check_dir + " ${env.WORKSPACE}"
}
