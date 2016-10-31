class gitlab_ci_multi_runner(
  Hash[String, Hash] $runner_instances,
  String $default_ci_token,
  String $default_download_url = 'https://gitlab-ci-multi-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-ci-multi-runner-linux-amd64',
  String $default_gitlab_ci_url = 'https://gitlab.com/ci',
  Array[String] $default_tags = ['puppet', 'rspec-puppet'],
  String $default_executor = 'shell',
  Optional[String] $admin_email = '',
) {
  $runner_options = {
    'gitlab_ci_url' => $default_gitlab_ci_url,
    'token' => $default_ci_token,
    'tags' => $default_tags,
    'executor' => $default_executor
  }

  $runner_instances.each |String $user, $options| {
      $toml_file_path = "/home/${user}/.gitlab-runner/config.toml"
      $instance_parameters = merge({'user' => $user,
        'admin_email' => $admin_email,
        'toml_file_path' => $toml_file_path,
        'download_url' => $default_download_url,
        'runner_default_options' => $runner_options}, $options)
      gitlab_ci_multi_runner::instance{$instance_parameters['user']:
        * => $instance_parameters
      }
  }

  Package['git'] -> Class['gitlab_ci_multi_runner::git_lfs']
  $package_list = ['git']
  package{$package_list:
    ensure => present
  }
  include gitlab_ci_multi_runner::git_lfs

}
