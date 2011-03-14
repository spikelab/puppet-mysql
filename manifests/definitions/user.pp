/*

== Definition: mysql::user

A basic helper used to create a user.

If mycnf is set it will create a ~/.my.cnf file for the user. For the time being this only works on linux with hardcoded home path to /home/$user

Example usage:
  mysql::user { "my user":
    user     => "foo",
    password => "bar",
    mycnf => "present|absent"
  }

Available parameters:
- *$ensure": defaults to present
- *$user*: the target user
- *$password*: user's password
- *$host*: target host, default to "localhost"
- *$mycnf*: if to create a .my.cnf file for the user or not. defaults to absent.

*/
define mysql::user($user, $password, $host="localhost", $ensure="present", $mycnf="absent", $privs="") {
	if $mysql_exists == "true" {
		if ! defined(Mysql_user["${user}@${host}"]) {
			mysql_user { "${user}@${host}":
        		        password_hash => mysql_password($password),
				require       => File["/root/.my.cnf"],
				ensure        => $ensure
			}
		}
		if $privs != "" and $ensure == "present"{
			mysql_grant { "${user}@${host}":
				privileges => $priv,
				require    => [File["/root/.my.cnf"],Mysql::User["${user}"]]
			}
		}
		# TOFIX variables reassigning necessary due to the template variables
		$mysql_user = $user
		$mysql_password = $password
		if $ensure == "absent" {
			$local_mycnf = "absent"
		} else {
			$local_mycnf = $mycnf
		}
		file{"/home/${user}/.my.cnf":
                       	ensure  => $local_mycnf,
			owner   => $user,
			mode    => 600,
			content => template("mysql/my.cnf.erb"),
		}
	}

}
