require 'spec_helper'
require 'shared_contexts'

describe 'gitlab_ci_multi_runner::instance' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  #include_context :hiera

  let(:title) { 'XXreplace_meXX' }
  
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
      #:user => $name,
      #:toml_file_path => (cat '/home/' (str $name) '/.gitlab-runner/config.toml'),
      #:home_path => (cat '/home/' (str $name) ''),
      #:download_url => 'https://gitlab-ci-multi-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-ci-multi-runner-linux-amd64',
      #:create_home_dir => true,
      #:service_name => (cat 'gitlab_runner_' (str $name) ''),
      #:install_service => true,
      #:ensure_service => 'running',
      #:manage_service => true,
    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
end
