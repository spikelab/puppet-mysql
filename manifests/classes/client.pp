#
# Class mysql::client
#
# Installs mysql client utilities such as mysqldump, mysqladmin, the "mysql"
# interactive shell, etc.
#
class mysql::client {
	package { "mysql-client":
		ensure => present,
		name   => $operatingsystem ? {
			/(?i)(RedHat|CentOS|Fedora)/   => "mysql",
			/(?i)(Debian|Ubuntu|kFreeBSD)/ => "mysql-client"
		}
	}
}
