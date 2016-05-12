class gitlab_ci_multi_runner::profiles::ruby_base(
  $puppet_package_name = 'pe-agent',
  $puppet_agent_download_url = 'http://pm.puppetlabs.com/puppet-agent/2015.3.0/1.3.2/repos/el/6/PC1/x86_64/puppet-agent-1.3.2-1.el6.x86_64.rpm',
) {

  unless defined(File['/usr/bin/ruby']) {
    # this is required because ruby creates the binary with /usr/bin/ruby
    file{'/usr/bin/ruby':
      ensure  => link,
      target  => '/opt/puppet/bin/ruby',
      require => Package[$puppet_package_name]
    }
  }
  package{$puppet_package_name:
    ensure => present,
    source => $puppet_agent_download_url,
  }

  file{'/var/tmp/bundler-1.11.2.gem':
    ensure => present,
    mode   => '0444',
    source => 'puppet:///modules/gitlab_ci_multi_runner/bundler-1.11.2.gem',
  }
  file{'/var/tmp/kwalify-0.7.2.gem':
    ensure => present,
    mode   => '0444',
    source => 'puppet:///modules/gitlab_ci_multi_runner/kwalify-0.7.2.gem',
  }
}
