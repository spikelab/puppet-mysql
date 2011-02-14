# Class: mysql::server::tuning

class mysql::server::tuning {
	Augeas {
		require => Class["mysql::server::config"],
		notify  => Class["mysql::server::service"]
	}
	
        # NOTE maybe to move to extlookup
        if ! $mysql_listen_on { $mysql_listen_on = "127.0.0.1" }
        if ! $mysql_sql_mode { $mysql_sql_mode = "STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER" }
        if ! $mysql_default_engine { $mysql_default_engine = "innodb" }
        if ! $mysql_character_set_server { $mysql_character_set_server = "utf8" }
        if ! $mysql_autocommit { $mysql_autocommit = "set autocommit=0" }

        augeas { "my.cnf/mysqld":
		context   => "$mycnfctx/mysqld/",
		load_path => "/usr/share/augeas/lenses/contrib/",
		changes   => [
			"set pid-file /var/run/mysqld/mysqld.pid",
			"set old_passwords 0",
			"set character-set-server utf8",
			"set log-warnings 1",
                        "set bind-address ${mysql_listen_on}",
                        "set character-set-server ${mysql_character_set_server}",
                        "set default-storage-engine ${mysql_default_engine}",
                        "set sql-mode ${mysql_sql_mode}",
                        "set init_connect ${mysql_autocommit}",
			$operatingsystem ? {
				/(?i)(RedHat|CentOS|Fedora)/ => "set log-error /var/log/mysqld.log",
				default                      => "set log-error /var/log/mysql/error.log"
			},
			$operatingsystem ? {
				/(?i)(RedHat|CentOS|Fedora)/ => "set slow-query-log /var/log/mysql-slow-queries.log",
				default                      => "set slow-query-log /var/log/mysql/mysql-slow.log"
			},
			#"ins log-slow-admin-statements after log-slow-queries", # BUG: not implemented in puppet yet
			$operatingsystem ? {
				/(?i)(RedHat|CentOS|Fedora)/ => "set socket /var/lib/mysql/mysql.sock",
				default                      => "set socket /var/run/mysqld/mysqld.sock"
			}
		]
	}

	# by default, replication is disabled
	augeas { "my.cnf/replication":
		context   => "$mycnfctx/mysqld/",
		load_path => "/usr/share/augeas/lenses/contrib/",
		changes   => [
			"rm log-bin",
      		"rm server-id",
			"rm master-host",
			"rm master-user",
			"rm master-password",
			"rm report-host"
		]
	}

	augeas { "my.cnf/mysqld_safe":
		context   => "$mycnfctx/mysqld_safe/",
		load_path => "/usr/share/augeas/lenses/contrib/",
		changes   => [
			"set pid-file /var/run/mysqld/mysqld.pid",
			$operatingsystem ? {
				/(?i)(RedHat|CentOS|Fedora)/ => "set socket /var/lib/mysql/mysql.sock",
				default                      => "set socket /var/run/mysqld/mysqld.sock"
			}
		]
	}

	# force use of system defaults
	augeas { "my.cnf/performance":
		context   => "$mycnfctx/",
		load_path => "/usr/share/augeas/lenses/contrib/",
		changes   => [
			"rm mysqld/key_buffer",
			"rm mysqld/max_allowed_packet",
			"rm mysqld/table_cache",
			"rm mysqld/sort_buffer_size",
			"rm mysqld/read_buffer_size",
			"rm mysqld/read_rnd_buffer_size",
			"rm mysqld/net_buffer_length",
			"rm mysqld/myisam_sort_buffer_size",
			"rm mysqld/thread_cache_size",
			"rm mysqld/query_cache_size",
			"rm mysqld/thread_concurrency",
			"rm mysqld/thread_stack",
			"rm mysqldump/max_allowed_packet",
			"rm isamchk/key_buffer",
			"rm isamchk/sort_buffer_size",
			"rm isamchk/read_buffer",
			"rm isamchk/write_buffer",
			"rm myisamchk/key_buffer",
			"rm myisamchk/sort_buffer_size",
			"rm myisamchk/read_buffer",
			"rm myisamchk/write_buffer"
		]
	}

	augeas { "my.cnf/client":
		context   => "$mycnfctx/client/",
		load_path => "/usr/share/augeas/lenses/contrib/",
		changes   => [
			$operatingsystem ? {
				/(?i)(RedHat|CentOS|Fedora)/ => "set socket /var/lib/mysql/mysql.sock",
				default                      => "set socket /var/run/mysqld/mysqld.sock"
			}
		]
	}
}
