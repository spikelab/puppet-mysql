# Class: mysql::master::huge inherits mysql::server::huge
#
#
class mysql::master::huge inherits mysql::server::huge {
	include mysql::slave
}
