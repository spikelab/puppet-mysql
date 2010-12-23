# Class: mysql::master::small inherits mysql::server::small
#
#
class mysql::master::small inherits mysql::server::small {
	include mysql::slave
}
