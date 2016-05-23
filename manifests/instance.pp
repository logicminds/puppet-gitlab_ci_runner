# sourced from instructions here:
# https://gitlab.com/gitlab-org/gitlab-ci-multi-runner/blob/master/docs/install/linux-manually.md

define gitlab_ci_multi_runner::instance(
  $user            = $name,
  $toml_file_path  = "/home/${name}/.gitlab-runner/config.toml",
  $home_path       = "/home/${name}",
  $download_url    = 'https://gitlab-ci-multi-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-ci-multi-runner-linux-amd64',
  $create_home_dir = true,
  $service_name    = "gitlab_${name}",
  $install_service = true,
  $ensure_service  = 'running',
  $manage_service  = true,
  $ssh_rsa_private_key = undef,
  $ssh_rsa_public_key  = undef,
  $ssh_key_password    = '',
  Optional[String] $admin_email = ''
) {
  include archive

  $runner_ci_binary = "${home_path}/gitlab-ci-multi-runner"
  user{$user:
    ensure     => present,
    managehome => true,
    shell      => '/bin/bash',
  }

  if $create_home_dir {
    file{$home_path:
      ensure  => directory,
      owner   => $user,
      group   => $group,
      require => User[$user],
      before  => [File["${home_path}/.gitlab-runner"],Archive[$runner_ci_binary]]
    }
  }
  file{"${home_path}/.gitlab-runner":
    ensure  => directory,
    before  => Archive[$runner_ci_binary],
    owner   => $user,
    group   => $user,
    require => User[$user]
  }
  archive {$runner_ci_binary:
    ensure  => present,
    extract => false,
    source  => $download_url,
    creates => $runner_ci_binary,
    cleanup => false,
  }
  file{$runner_ci_binary:
    ensure  => file,
    mode    => '0555',
    owner   => $user,
    group   => $user,
    require => Archive[$runner_ci_binary]
  }
  # since we need to figure out when to not install the service
  # we have to guess where the server file will be installed
  $service_file = $::osfamily ? {
    'RedHat'   => $::operatingsystemrelease ? {
      /^(5.*|6.*)/ => "/etc/init.d/${service_name}",
      default      => "/etc/systemd/system/${service_name}.service",
    },
    'deb'   => "/etc/init/${service_name}.conf",
    default => '/bin/true',
  }
  # Install Service as user instance
  if $install_service {
    start_repl
    exec { "Enable ${service_name}":
      command   => "${runner_ci_binary} install --user ${user} --service ${service_name} --config ${toml_file_path} --working-directory ${home_path}",
      user      => root,
      provider  => shell,
      creates   => $service_file,
      subscribe => Archive[$runner_ci_binary],
    }
    if $manage_service {
      service{$service_name:
        ensure    => $ensure_service,
        enable    => true,
        hasstatus => true,
        subscribe => Exec["Enable ${service_name}"]
      }
    }
  }
  ssh::ssh_keys{ "${user} - runner_key":
    system_key_user      => $user,
    system_user_home_dir => $home_path,
    key_password         => $ssh_key_password,
    ssh_rsa_public_key   => $ssh_rsa_public_key,
    ssh_rsa_private_key  => $ssh_rsa_private_key,
    require              => File[$runner_ci_binary],
  }
  # this allows connections to ssh server to use a single connection rather than establishing multiple connections
  file{ "${home_path}/.ssh/config":
    ensure  => present,
    owner   => $user,
    group   => $user,
    require => Ssh::Ssh_keys["${user} - runner_key"],
    content => "Host *\nControlMaster auto\nControlPath ${home_path}/.ssh/ssh-%r@%h:%p"
  }
  if $admin_email != '' {
    exec{"send ${user} ssh key":
      path => ['/bin', '/usr/sbin', '/usr/local/bin'],
      command => "cat ${ssh_rsa_public_key} | mail -s '${user} ssh key, add this to gitlab ci_runner ssh keys' ${admin_email}",
      refreshonly => true,
      subscribe => Ssh::Ssh_keys["${user} - runner_key"]
    }
  }
}
