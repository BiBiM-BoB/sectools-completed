stage('ggshield') {
  def ggshield_dir = 'SIS/ggshield/script/run.sh'
  sh 'chmod +x ' + components_dir + ggshield_dir
  sh components_dir + 'SIS/ggshield/script/run.sh' + " ${env.WORKSPACE}"
}
