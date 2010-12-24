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
