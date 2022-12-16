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
        echo 'This branch is ' + scmVars.GIT_BRANCH
        echo 'Target branch is ' + branch
        
        if (scmVars.GIT_BRANCH != branch) {
            echo '[ALERT] This branch is not a target'
            currentBuild.result = 'SUCCESS'
            sh "exit ${branch}"
        }
    }
        
    def components_dir = "${JENKINS_HOME}" + '/userContent/components/'
