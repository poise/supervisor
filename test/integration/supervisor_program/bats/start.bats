@test 'program-started was not automatically started' {
    grep 'autostart=false' /etc/supervisor.d/program-started.conf
}

@test 'program-started has been manually started' {
    supervisorctl status program-started | grep 'RUNNING'
}
