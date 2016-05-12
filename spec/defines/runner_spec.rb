require 'spec_helper'
require 'shared_contexts'

describe 'gitlab_ci_multi_runner::runner' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  #include_context :hiera

  let(:title) { 'test_runner' }
  
  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {}
  end
  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      :gitlab_ci_url => 'https://gitlab.com/ci',
      #:tags => undef,
      :token => '12334',
      :toml_file => '/etc/gitlab/gitlab-runner/config.toml',
      #:env => undef,
      #:executor => undef,
      #:docker_image => undef,
      #:docker_privileged => undef,
      #:docker_mysql => undef,
      #:docker_postgres => undef,
      #:docker_redis => undef,
      #:docker_mongo => undef,
      #:docker_allowed_images => undef,
      #:docker_allowed_services => undef,
      #:parallels_vm => undef,
      #:ssh_host => undef,
      #:ssh_port => undef,
      #:ssh_user => undef,
      #:ssh_password => undef,
      #:require => [Class["gitlab_ci_multi_runner"]],
      :user => 'user123'
    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  it do
    is_expected.to contain_exec('Register-test_runner')
      .with(
        'cwd'      => '/home/user123',
        'unless'   => 'grep test_runner /etc/gitlab/gitlab-runner/config.toml',
        'provider' => 'shell',
        'user'     => 'user123'
      )
  end
end
