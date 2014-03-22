@test 'check server process is running' {
    ps -e | grep supervisord
}

@test 'check unix socket has been created' {
    test -S /var/run/supervisor.sock
}
