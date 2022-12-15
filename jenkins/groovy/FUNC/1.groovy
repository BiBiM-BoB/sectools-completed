def stop_container(container_name) {
    sh 'docker stop ' + container_name
}

def exec(container_name, command) {
    try {
        def cmd = 'docker exec ' + container_name + ' ' + command
        sh cmd
    } catch(error) {
        stop_container(container_name)
    }
}

node {
  // need to change user automatically
    def components_dir = "${JENKINS_HOME}" + '/userContent/components/'
