@test 'config file for program-disabled was deleted' {
    [ ! -f /etc/supervisor.d/program-disabled.conf ]
}

@test 'program-disabled has been removed from supervisor' {
    supervisorctl status program-disabled | grep '^No such process'
}
