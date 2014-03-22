@test 'program-stopped was automatically started' {
    grep 'autostart=true' /etc/supervisor.d/program-stopped.conf
}

@test 'program-stopped has been manually stopped' {
    supervisorctl status program-stopped | grep 'STOPPED'
}
