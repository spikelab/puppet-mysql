class mysql::server::innodb inherits mysql::server::tuning {
  if ! $mysql_innodb_additional_mem_pool_size { $innodb_additional_mem_pool_size = "16M" }
  if ! $innodb_autoinc_lock_mode { $innodb_autoinc_lock_mode = "1" }
  if ! $innodb_buffer_pool_size { $innodb_buffer_pool_size = "12G" }
  if ! $innodb_data_file_path { $innodb_data_file_path = "ibdata1:10M:autoextend"}
  if ! $innodb_flush_log_at_trx_commit { $innodb_flush_log_at_trx_commit = "1" }
  if ! $innodb_lock_wait_timeout { $innodb_lock_wait_timeout = "50" }
  if ! $innodb_log_buffer_size { $innodb_log_buffer_size = "16M" }
  if ! $innodb_log_file_size { $innodb_log_file_size = "5M" }
  Augeas["my.cnf/innodb"]{
    changes => [
      "set innodb_additional_mem_pool_size ${innodb_additional_mem_pool_size}",
      "set innodb_autoinc_lock_mode ${innodb_autoinc_lock_mode}",
      "set innodb_buffer_pool_size ${innodb_buffer_pool_size}",
      "set innodb_data_file_path ${innodb_data_file_path}",
      "set innodb_flush_log_at_trx_commit ${innodb_flush_log_at_trx_commit}",
      "set innodb_lock_wait_timeout ${innodb_lock_wait_timeout}",
      "set innodb_log_buffer_size ${innodb_log_buffer_size}",
      "set innodb_log_file_size ${innodb_log_file_size}"
    ],
  }
}

class mysql::server::innodb::small inherits mysql::server::innodb {
  Augeas["my.cnf/innodb"]{
    changes +> [
      "set innodb_additional_mem_pool_size 4M",
      "set innodb_buffer_pool_size 256M",
      "set innodb_log_buffer_size 8M",
    ],
  }
}
