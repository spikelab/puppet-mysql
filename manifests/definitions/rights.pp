/*

== Definition: mysql::rights

A basic helper used to grant privileges to a user on a database or globally. If
the "database" attribute is missing the privs will be assigned globally.

Example usage:
  mysql::rights { "example case":
    user     => "foo",
    password => "bar",
    database => "mydata",
    priv    => ["select_priv", "update_priv"]
  }

Available parameters:
- *$database*: the target database
- *$user*: the target user
- *$host*: target host, default to "localhost"
- *$priv*: target privileges, defaults to "all" (values are the fieldnames from mysql.db table).

*/
define mysql::rights($database="", $user, $host="localhost", $privs="all") {
	if $mysql_exists == "true"{
		mysql_grant { "${user}@${host}/${database}":
			privileges => $privs,
			require    => [File["/root/.my.cnf"],Mysql::User["${user}"]]
		}
	}
}
