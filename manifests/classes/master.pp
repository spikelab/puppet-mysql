class mysql::master inherits mysql::server {
	Augeas["my.cnf/replication"] {
		changes => [
			"set log-bin mysqld-bin",
			"set server-id ${mysql_serverid}",
			"set expire_logs_days 7",
			"set max_binlog_size 100M"
		],
	}

	if $mysql_binlog_format {
		augeas { "my.cnf/binlog-format":
			context => "$mycnfctx/mysqld/",
			changes => [
				"set binlog-format ${mysql_binlog_format}"
			],
		}
	}
}
