# Class: mysql::server::config
#
#
class mysql::server::config {
	File {
		require => Class["mysql::server::install"],
		notify  => Class["mysql::server::service"]
	}
	
	file { "/etc/mysql/my.cnf":
		ensure  => present,
		path    => $mycnf,
		owner   => root,
		group   => root,
		mode    => 644,
		seltype => "mysqld_etc_t"
	}
	
	file { "/var/lib/mysql":
		ensure  => directory,
		owner   => "mysql",
		group   => "mysql",
		mode    => 700,
		seltype => "mysqld_db_t"
	}
	
	file { "/usr/share/augeas/lenses/mysql.aug":
		ensure => present,
		source => "puppet:///modules/mysql/mysql.aug"
	}
	
	logrotate::file { "mysql-server":
		source => $operatingsystem ? {
			/(?i)(RedHat|CentOS|Fedora)/   => "puppet:///modules/mysql/logrotate.redhat",
			/(?i)(Debian|Ubuntu|kFreeBSD)/ => "puppet:///modules/mysql/logrotate.debian",
			default                        => undef
			}
	}
}
