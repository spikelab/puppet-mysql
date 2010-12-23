# Class: mysql::server::service
#
#
class mysql::server::service {
	service { "mysql":
		ensure  => running,
		enable  => $mysql_run_at_boot,
		name    => $operatingsystem ? {
			/(?i)(RedHat|CentOS|Fedora)/ => "mysqld",
			default                      => "mysql"
		},
		require => Class["mysql::server::config"]
	}
}
