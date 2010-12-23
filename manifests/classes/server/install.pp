# Class: mysql::server::install
#
#
class mysql::server::install {
	package { "mysql-server":
		ensure => installed
	}
	
	user { "mysql":
		ensure  => present,
		require => Package["mysql-server"]
	}
}
