class mysql::slave inherits mysql::master {
	augeas { "my.cnf/slave-replication":
		context => "$mycnfctx/mysqld/",
		changes => [
			"set relay-log mysqld-relay-bin",
			$mysql_skip_slave_start ? {
				true    => "set skip-slave-start 1",
				default => "rm skip-slave-start"
			}
		]
	}
        if $mysql_replicate_do_db {
            augeas { "my.cnf/replication-db":
                context    => "$mycnfctx/mysqld/",
                load_path  => "/usr/share/augeas/lenses/contrib/",
                changes    => [
                               "set replicate_do_db ${mysql_replicate_do_db}",
                              ],
            }
        }

        if $mysql_replicate_rewrite_db {
            augeas { "my.cnf/replication-rewrite-db":
                context    => "$mycnfctx/mysqld/",
                load_path  => "/usr/share/augeas/lenses/contrib/",
                changes    => [
                               "set replicate-rewrite-db ${mysql_replicate_rewrite_db}",
                              ],
            }
        }
}
