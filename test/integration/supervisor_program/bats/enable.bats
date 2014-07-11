@test 'config file for program-enabled was created' {
    [ -f /etc/supervisor.d/program-enabled.conf ]
}

@test 'program-enabled has been added to supervisor' {
    supervisorctl status program-enabled | grep '^program-enabled'
}
