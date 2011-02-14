class mysql::administration {

# TODO:
# - permissions to edit my.cnf once augeas bug is corrected (see
#   modules/cognac/manifests/classes/mysql-slave.pp)
# - .my.cnf for people in %mysql-admin
	group { "mysql-admin":
		ensure => present,
	}

	$distro_specific_mysql_sudo = $operatingsystem ? {
		/(?i)(RedHat|CentOS|Fedora)/   => "/etc/init.d/mysqld, /sbin/service mysqld",
		/(?i)(Debian|Ubuntu|kFreeBSD)/ => "/etc/init.d/mysql"
	}
	
	concat::fragment { "sudoers.mysql":
		target  => "/etc/sudoers",
		order   => 20,
		content => template("mysql/sudoers.erb"),
		require => Group["mysql-admin"]
	}
}
