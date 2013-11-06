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

@test "supervisor EXE ownership" {
	test `stat --format='%U' /opt/supervisor/bin/supervisord` = supervisor
}

@test "/etc/supervisor.d ownership" {
	test `stat --format='%U' /etc/supervisor.d` = root
	test `stat --format='%G' /etc/supervisor.d` = superadm
}

@test "/etc/default/supervisor ownership" {
	skip_unless_ubuntu
	test `stat --format='%U' /etc/default/supervisor` = root
	test `stat --format='%G' /etc/default/supervisor` = superadm
}

@test "/etc/init.d/supervisor ownership" {
	skip_unless_ubuntu
	test `stat --format='%U' /etc/init.d/supervisor` = root
	test `stat --format='%G' /etc/init.d/supervisor` = superadm
}

@test "log is writable by daemon" {
	sudo -u supervisor touch /var/log/supervisor/REMOVEME
	rm -f /var/log/supervisor/REMOVEME
}

@test "supervisor init file contains appropriate path" {
	skip_unless_ubuntu
	grep -q 'PATH=.*/opt/supervisor/bin' /etc/init.d/supervisor
}

@test "supervisor service is running" {
	skip_unless_ubuntu
	service supervisor status | grep -q running
}
