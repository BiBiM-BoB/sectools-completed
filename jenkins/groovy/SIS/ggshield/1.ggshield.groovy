stage('ggshield') {
  def ggshield_dir = 'SIS/ggshield/srcipt/run.sh'
  sh 'chmod +x ' + components_dir + ggshield_dir
  sh components_dir + 'SIS/ggshield/srcipt/run.sh' + " ${env.WORKSPACE}"
}
