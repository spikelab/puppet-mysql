# Class: mysql::master::large inherits mysql::server::large
#
#
class mysql::master::large inherits mysql::server::large {
	include mysql::slave
}
