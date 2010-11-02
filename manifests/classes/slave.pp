class mysql::slave inherits mysql::master {

  augeas { "my.cnf/slave-replication":
    context => "$mycnfctx/mysqld/",
    changes => [
      "set relay-log mysqld-relay-bin",
      $mysql_skip_slave_start ? {
        true => "set skip-slave-start 1",
        default => "rm skip-slave-start",
      }
    ],
  }
}
