skip_unless_ubuntu() {
	if test ! -e /etc/debian_version; then
		skip ${1:-"only valid on debian-based systems"}
	fi
}

@test "supervisor installed into virtualenv" {
	/opt/supervisor/bin/pip freeze | grep -q supervisor
}

@test "supervisor configuration is in /etc" {
	test -d /etc/supervisor.d
	test -e /etc/supervisord.conf
}

@test "supervisor init file contains appropriate path" {
	skip_unless_ubuntu
	grep -q 'PATH=.*/opt/supervisor/bin' /etc/init.d/supervisor
}

@test "supervisor service is running" {
	skip_unless_ubuntu
	service supervisor status | grep -q running
}
