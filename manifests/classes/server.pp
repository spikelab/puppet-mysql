/*
==Class: mysql::server

Parameters:
 $mysql_data_dir:
   set the data directory path, which is used to store all the databases

   If set, copies the content of the default mysql data location. This is
   necessary on Debian systems because the package installation script
   creates a special user used by the init scripts.

*/
class mysql::server {
	if ! ($mysql_run_at_boot == true or $mysql_run_at_boot == false) { $mysql_run_at_boot = true }

	$mycnf = $operatingsystem ? {
		/(?i)(RedHat|CentOS|Fedora)/ => "/etc/my.cnf",
		default                      => "/etc/mysql/my.cnf"
	}

	$mycnfctx = "/files/${mycnf}"

	if $mysql_user {} else { $mysql_user = "root" }

	include mysql::server::install, mysql::server::config, mysql::server::service, mysql::server::initialize, mysql::server::tuning
}
