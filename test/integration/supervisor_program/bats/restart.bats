@test 'program-restarted is still running' {
    supervisorctl status program-restarted | grep 'RUNNING'
}

@test 'program-restarted has been restarted' {
    set -- $(cat /tmp/program-restarted.log)
    [ $# -eq 2 -a $1 -le $(( $2 - 5 )) ]
}
