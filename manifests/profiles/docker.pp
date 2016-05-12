# sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
# [dockerrepo]
# name=Docker Repository
# baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
# enabled=1
# gpgcheck=1
# gpgkey=https://yum.dockerproject.org/gpg
# EOF
class gitlab_ci_multi_runner::profiles::docker(

  )
{
  yumrepo{'dockerrepo':
    ensure   => present,
    baseurl => 'https://yum.dockerproject.org/repo/main/centos/$releasever',
    enabled => 1,
    gpgcheck => 1,
    gpgkey => 'https://yum.dockerproject.org/gpg'
  } ->
  package{'docker-engine':
    ensure => latest
  } ~>
  service{'docker':
    ensure => running,
    enable => true,
  }
  group{'docker':
    ensure => present,
  }
}
