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
		log        => $operatingsystem ? {
			/(?i)(RedHat|CentOS|Fedora)/ => "/var/log/mysqld.log /var/log/mysql-queries.log /var/log/mysql-slow-queries.log",
			default                      => "/var/log/mysql.log /var/log/mysql/mysql.log /var/log/mysql/mysql-slow.log"
			},
		options    => [ "daily", "rotate 7", "missingok", "create 640 mysql mysql", "compress", "sharedscripts" ],
		postrotate => "export MYADMIN="/usr/bin/mysqladmin --defaults-extra-file=/root/.my.cnf"
        			   test -x /usr/bin/mysqladmin || exit 0
        			   if ! $MYADMIN ping 2>&1 > /dev/null; then
          			   	   echo "mysql not running" && exit 1
        			   else
          			   	   $MYADMIN flush-logs
        			   fi"
	}
	
	if $mysql_password {
		if $mysql_exists == "true" {
			mysql_user { "${mysql_user}@localhost":
				ensure        => present,
				password_hash => mysql_password($mysql_password),
				require       => Exec["Generate my.cnf"]
			}
		}

		file { "/root/.my.cnf":
			ensure  => present,
			owner   => root,
			group   => root,
			mode    => 600,
			content => template("mysql/my.cnf.erb"),
			require => Exec["Initialize MySQL server root password"]
		}
	} else {
		$mysql_password = inline_template("<%= (1..25).collect{|a| (('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + %w(% & * + - : ? @ ^ _))[rand(75)] }.join %>")
		
		file { "/root/.my.cnf":
			owner   => root,
			group   => root,
			mode    => 600,
			require => Exec["Initialize MySQL server root password"]
		}
	}

	exec { "Initialize MySQL server root password":
		unless  => "test -f /root/.my.cnf",
		command => "mysqladmin -u${mysql_user} password '${mysql_password}'",
		notify  => Exec["Generate my.cnf"],
		require => [ Class["mysql::server::install"], Class["mysql::server::service"]]
	}

	exec { "Generate my.cnf":
		command     => "/bin/echo -e '[mysql]\\nuser=${mysql_user}\\npassword=${mysql_password}\\n[mysqladmin]\\nuser=${mysql_user}\\npassword=${mysql_password}\\n[mysqldump]\\nuser=${mysql_user}\\npassword=${mysql_password}\\n[mysqlshow]\\nuser=${mysql_user}\\npassword=${mysql_password}\\n' > /root/.my.cnf",
		refreshonly => true,
		creates     => "/root/.my.cnf"
	}

	# Remove unneeded extra "root@127.0.0.1" and "root@host" users
	if $mysql_exists == "true" {
		mysql_user {
			"root@127.0.0.1":
				ensure  => absent,
				require => File['/root/.my.cnf'];
			"root@$hostname":
        		ensure  => absent,
				require => File['/root/.my.cnf'];
		}
	}
}
