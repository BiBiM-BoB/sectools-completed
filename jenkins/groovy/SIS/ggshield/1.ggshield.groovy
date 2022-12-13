stage('ggshield') {
  sh components_dir + "SIS/ggshield/run.sh ${env.WORKSPACE}"
}