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

def scmVars

node {
    dir("${env.WORKSPACE}") {
        sh "pwd"
    }
    stage('checkout scm') {
        scmVars = checkout scm
    }
    stage('check branch') {
        echo 'branch is ' + scmVars.GIT_BRANCH
        
        if (scmVars.GIT_BRANCH != branch) {
            currentBuild.result = 'SUCCESS'
            return
        }
    }
        
    def components_dir = "${JENKINS_HOME}" + '/userContent/components/'
