class gitlab_ci_multi_runner::git_lfs(
  $git_lfs_file_url = 'https://github.com/github/git-lfs/releases/download/v1.1.0/git-lfs-linux-amd64-1.1.0.tar.gz',
) {
  include archive

  archive {'/opt/git-lfs.tar.gz':
    ensure       => present,
    extract      => true,
    extract_path => '/opt',
    source       => $git_lfs_file_url,
    creates      => '/usr/bin/git-lfs',
    cleanup      => true,
  } ->
  exec{'run git-lfs installer':
    environment => ['PREFIX=/usr'],
    command     => '/bin/bash /opt/git-lfs-1.1.0/install.sh',
    cwd         => '/opt/git-lfs-1.1.0',
    creates     => '/usr/bin/git-lfs',
    path        => ['/bin', '/usr/bin', '/usr/local/bin', '/usr/sbin'],
    logoutput   => true,
  }

}