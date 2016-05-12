define gitlab_ci_multi_runner::profiles::puppet_pe_38(
  $user,
  $user_path,
  $puppet_gems_bundle = 'file:///etc/puppet/modules/gitlab_ci_multi_runner/files/ruby_pe_3_8_test_gems.tar.gz',
  $puppet_package_name = 'pe-agent',
  $puppet_agent_download_url = 'http://pm.puppetlabs.com/puppet-agent/2015.3.0/1.3.2/repos/el/6/PC1/x86_64/puppet-agent-1.3.2-1.el6.x86_64.rpm',
) {

  unless defined(Class['gitlab_ci_multi_runner::profiles::ruby_base']) {
    class{'gitlab_ci_multi_runner::profiles::ruby_base':
      puppet_package_name       => $puppet_package_name,
      puppet_agent_download_url => $puppet_agent_download_url,
    }
  }


  # version : 2015.02.2 - http://pm.puppetlabs.com/puppet-agent/2015.2.2/1.2.6/repos/el/6/PC1/x86_64/puppet-agent-1.2.6-1.el6.x86_64.rpm?_ga=1.147914161.749876131.1448300704
  # version : 3.8.3 - https://pm.puppetlabs.com/puppet-enterprise/3.8.3/puppet-enterprise-3.8.3-el-6-x86_64-agent.tar.gz?_ga=1.207140117.749876131.1448300704
  if $::puppetversion =~ /Puppet Enterprise/ and $::osfamily != 'Windows' {
    $gem_provider = 'pe_gem'
  } elsif $::aio_agent_version {
    $gem_provider = 'puppet_gem'
  } else {
    if versioncmp($::puppetversion, '4.0.0') >= 0 {
      $gem_provider = 'puppet_gem'
    } else {
      $gem_provider = 'gem'
    }
  }
  exec{"${user}-kwalify":
    environment => ["HOME=${user_path}", "GEM_HOME=${user_path}/.gems"],
    path        => ['/opt/puppet/bin', '/usr/bin', '/bin' ],
    command     => 'gem install --local --no-rdoc --no-ri /var/tmp/kwalify-0.7.2.gem',
    creates     => "${user_path}/bin/kwalify",
    require     => File['/var/tmp/kwalify-0.7.2.gem'],
    provider    => shell,
    logoutput   => true,
    user        => $user,

  }
  exec{"${user}-bundler":
    environment => ["HOME=${user_path}", "GEM_HOME=${user_path}/.gems"],
    path        => ['/opt/puppet/bin', '/usr/bin', '/bin' ],
    command     => 'gem install --local --no-rdoc --no-ri /var/tmp/bundler-1.11.2.gem',
    creates     => "${user_path}/bin/bundle",
    require     => File['/var/tmp/bundler-1.11.2.gem'],
    provider    => shell,
    logoutput   => true,
    user        => $user,
  }

  file{"${user_path}/.gemrc":
    ensure  => present,
    content => "gem: --no-ri --no-rdoc --bindir ~/bin\ngemdir: ~/.gems",
    require => File["${user_path}/.bash_profile"]
  }

  exec{"${user} set bundle config":
    path        => ["${user_path}/bin", '/opt/puppetlabs/bin', '/opt/puppetlabs/puppet/bin', '/bin', '/usr/bin', '/opt/puppet/bin'],
    command     => "bundle config --global path '${user_path}/vendor/bundle' && bundle config --global disable_shared_gems 1 && bundle config --global frozen 1",
    environment => ["HOME=${user_path}", "GEM_HOME=${user_path}/.gems"],
    user        => $user,
    provider    => 'shell',
    unless      => "bundle config |grep '${user_path}/vendor/bundle' ",
    logoutput   => true,
    require     => [Exec["${user}-bundler"], File["${user_path}/.bash_profile"]]
  }
  file{"${user_path}/.bash_profile":
    ensure => present,
    mode   => '0644',
    owner  => $user,
    group  => $user,
    source => 'puppet:///modules/gitlab_ci_multi_runner/bash_profile',
  }
  archive{"${user_path}/puppet_gems_bundle.tar.gz":
    ensure       => present,
    extract      => true,
    #checksum      => $file1_sha1_checksum,
    #checksum_type => 'sha1',
    source       => $puppet_gems_bundle,
    creates      => "${user_path}/vendor",
    cleanup      => true,
    user         => $user,
    group        => $user,
    extract_path => $user_path,
  }

  # In order the package the gems you must do the following
  # on a like machine, whatever os/version your target platform is
  # ensure the same version of puppet is installed (pe preferred)
  # yum install gcc gcc-c++ zlib-devel git
  # useradd ci_builder && su - ci_builder
  # mkdir build && cd build && cp Gemfile.ci_runner from this project
  #
  # cp the bash profile and gemrc referenced in the resources above
  # source the bash profile
  # gem install bundler
  # bundle install
  # bundle install --deployment --path ~/vendor
  # running this command will build all the gems under ~/vendor
  # this command would need to be run for each version of ruby you deploy to
  # cd ~ && tar -zcvf rubygems_puppet.tar.gz ./vendor
  # useful commands
  # bundle install --no-deployment  (after using --deployment)
}
