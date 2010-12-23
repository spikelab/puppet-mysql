# Class: mysql::slave::small inherits mysql::server::small
#
#
class mysql::slave::small inherits mysql::server::small {
	include mysql::slave
}
