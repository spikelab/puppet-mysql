class mysql::server {

  if ! ($mysql_run_at_boot == true or $mysql_run_at_boot == false) { $mysql_run_at_boot = true }

  $mycnf = $operatingsystem ? {
    /RedHat|Fedora|CentOS/ => "/etc/my.cnf",
    default => "/etc/mysql/my.cnf",
  }

  $mycnfctx = "/files/${mycnf}"

  user { "mysql":
    ensure => present,
    require => Package["mysql-server"],
  }

  package { "mysql-server":
    ensure => installed,
  }

  file { "/etc/mysql/my.cnf":
    ensure => present,
    path => $mycnf,
    owner => root,
    group => root,
    mode => 644,
    seltype => "mysqld_etc_t",
    require => Package["mysql-server"],
  }

  file { "/usr/share/augeas/lenses/mysql.aug":
    ensure => present,
    source => "puppet:///modules/mysql/mysql.aug",
  }

  augeas { "my.cnf/mysqld":
    context => "$mycnfctx/mysqld/",
    load_path => "/usr/share/augeas/lenses/contrib/",
    changes => [
      "set pid-file /var/run/mysqld/mysqld.pid",
      "set old_passwords 0",
      "set character-set-server utf8",
      "set log-warnings 1",
      $operatingsystem ? {
        /RedHat|Fedora|CentOS/ => "set log-error /var/log/mysqld.log",
        default => "set log-error /var/log/mysql.err",
      },
      $operatingsystem ? {
        /RedHat|Fedora|CentOS/ => "set log-slow-queries /var/log/mysql-slow-queries.log",
        default => "set set log-slow-queries /var/log/mysql/mysql-slow.log",
      },
      #"ins log-slow-admin-statements after log-slow-queries", # BUG: not implemented in puppet yet
      $operatingsystem ? {
        /RedHat|Fedora|CentOS/ => "set socket /var/lib/mysql/mysql.sock",
        default => "set socket /var/run/mysqld/mysqld.sock",
      }
    ],
    require => File["/etc/mysql/my.cnf"],
    notify => Service["mysql"],
  }

  # by default, replication is disabled
  augeas { "my.cnf/replication":
    context => "$mycnfctx/mysqld/",
    load_path => "/usr/share/augeas/lenses/contrib/",
    changes => [
      "rm log-bin",
      "rm server-id",
      "rm master-host",
      "rm master-user",
      "rm master-password",
      "rm report-host"
    ],
    require => File["/etc/mysql/my.cnf"],
    notify => Service["mysql"],
  }

  augeas { "my.cnf/mysqld_safe":
    context => "$mycnfctx/mysqld_safe/",
    load_path => "/usr/share/augeas/lenses/contrib/",
    changes => [
      "set pid-file /var/run/mysqld/mysqld.pid",
      $operatingsystem ? {
        /RedHat|Fedora|CentOS/ => "set socket /var/lib/mysql/mysql.sock",
        default => "set socket /var/run/mysqld/mysqld.sock",
      }
    ],
    require => File["/etc/mysql/my.cnf"],
    notify => Service["mysql"],
  }

  # force use of system defaults
  augeas { "my.cnf/performance":
    context => "$mycnfctx/",
    load_path => "/usr/share/augeas/lenses/contrib/",
    changes => [
     "rm mysqld/key_buffer",
     "rm mysqld/max_allowed_packet",
     "rm mysqld/table_cache",
     "rm mysqld/sort_buffer_size",
     "rm mysqld/read_buffer_size",
     "rm mysqld/read_rnd_buffer_size",
     "rm mysqld/net_buffer_length",
     "rm mysqld/myisam_sort_buffer_size",
     "rm mysqld/thread_cache_size",
     "rm mysqld/query_cache_size",
     "rm mysqld/thread_concurrency",
     "rm mysqld/thread_stack",
     "rm mysqldump/max_allowed_packet",
     "rm isamchk/key_buffer",
     "rm isamchk/sort_buffer_size",
     "rm isamchk/read_buffer",
     "rm isamchk/write_buffer",
     "rm myisamchk/key_buffer",
     "rm myisamchk/sort_buffer_size",
     "rm myisamchk/read_buffer",
     "rm myisamchk/write_buffer"
    ],
    require => File["/etc/mysql/my.cnf"],
    notify => Service["mysql"],
  }

  augeas { "my.cnf/client":
    context => "$mycnfctx/client/",
    load_path => "/usr/share/augeas/lenses/contrib/",
    changes => [
      $operatingsystem ? {
        /RedHat|Fedora|CentOS/ => "set socket /var/lib/mysql/mysql.sock",
        default => "set socket /var/run/mysqld/mysqld.sock",
      }
    ],
    require => File["/etc/mysql/my.cnf"],
  }

  service { "mysql":
    ensure      => running,
    enable      => $mysql_run_at_boot,
    name        => $operatingsystem ? {
      /RedHat|Fedora|CentOS/ => "mysqld",
      default => "mysql",
    },
    require   => Package["mysql-server"],
  }


  if $mysql_user {} else { $mysql_user = "root" }

  if $mysql_password {

    if $mysql_exists == "true" {
      mysql_user { "${mysql_user}@localhost":
        ensure => present,
        password_hash => mysql_password($mysql_password),
        require => Exec["Generate my.cnf"],
      }
    }

    file { "/root/.my.cnf":
      ensure => present,
      owner => root,
      group => root,
      mode  => 600,
      content => template("mysql/my.cnf.erb"),
      require => Exec["Initialize MySQL server root password"],
    }

  } else {

    $mysql_password = inline_template("<%= (1..25).collect{|a| (('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + %w(% & * + - : ? @ ^ _))[rand(75)] }.join %>")

    file { "/root/.my.cnf":
      owner => root,
      group => root,
      mode  => 600,
      require => Exec["Initialize MySQL server root password"],
    }

  }

  exec { "Initialize MySQL server root password":
    unless      => "test -f /root/.my.cnf",
    command     => "mysqladmin -u${mysql_user} password '${mysql_password}'",
    notify      => Exec["Generate my.cnf"],
    require     => [Package["mysql-server"], Service["mysql"]]
  }

  exec { "Generate my.cnf":
    command     => "/bin/echo -e '[mysql]\\nuser=${mysql_user}\\npassword=${mysql_password}\\n[mysqladmin]\\nuser=${mysql_user}\\npassword=${mysql_password}\\n[mysqldump]\\nuser=${mysql_user}\\npassword=${mysql_password}\\n[mysqlshow]\\nuser=${mysql_user}\\npassword=${mysql_password}\\n' > /root/.my.cnf",
    refreshonly => true,
    creates     => "/root/.my.cnf",
  }

  # Remove unneeded extra "root@127.0.0.1" and "root@host" users
  if $mysql_exists == "true" {
    mysql_user {
      "root@127.0.0.1":
        ensure => absent,
        require => File['/root/.my.cnf'];
      "root@$hostname":
        ensure => absent,
        require => File['/root/.my.cnf'];
    }
  }

  file { "/var/lib/mysql":
    ensure  => directory,
    owner   => "mysql",
    group   => "mysql",
    mode    => 700,
    seltype => "mysqld_db_t",
    require => Package["mysql-server"],
  }

  file { "/etc/logrotate.d/mysql-server":
    ensure => present,
    source => $operatingsystem ? {
      /RedHat|Fedora|CentOS/ => "puppet:///modules/mysql/logrotate.redhat",
      default => undef,
    }
  }

}
