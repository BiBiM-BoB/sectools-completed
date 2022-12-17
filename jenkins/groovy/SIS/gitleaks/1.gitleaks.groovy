stage('gitleaks') {
  def gitleaks_dir = 'SIS/gitleaks/script/run.sh'
  sh 'chmod +x ' + components_dir + gitleaks_dir
  sh components_dir + gitleaks_dir + " ${env.WORKSPACE}" + " ${pipeline_name}"
}
