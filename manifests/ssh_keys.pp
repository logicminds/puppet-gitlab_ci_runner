define gitlab_ci_multi_runner::ssh_keys(
  $system_key_user,
  $system_user_home_dir,
  $key_password = '',  # the default will be no password
  $ssh_rsa_public_key = undef,
  $ssh_rsa_private_key = undef,
) {
  # ssh-keygen for user
  # you will then need to add this key to the gitlab account
  if $ssh_rsa_private_key == undef {
    exec{ "${system_user_home_dir} generate_key":
      path    => ['/bin', '/usr/bin', '/usr/sbin'],
      user    => $system_key_user,
      command => "cat /dev/zero | ssh-keygen -t rsa -b 2048 -q -N '${key_password}'",
      creates => "${system_user_home_dir}/.ssh/id_rsa",
      require => File[$system_user_home_dir]
    }
  }
    # if you want to use pregenerated keys, then we can just
    # reuse them here
  else {
    file{"${system_user_home_dir}/.ssh":
      ensure => directory,
      owner  => $system_key_user,
      group  => $system_key_user,
    }
    file{"${system_user_home_dir}/.ssh/id_rsa":
      ensure  => file,
      content => $ssh_rsa_private_key,
      owner   => $system_key_user,
      group   => $system_key_user,
      mode    => '0600',
      require => File["${system_user_home_dir}/.ssh"]
    }
    file{"${system_user_home_dir}/.ssh/id_rsa.pub":
      ensure  => file,
      content => $ssh_rsa_public_key,
      mode    => '0644',
      owner   => $system_key_user,
      group   => $system_key_user,
      require => File["${system_user_home_dir}/.ssh"]
    }
  }
}
