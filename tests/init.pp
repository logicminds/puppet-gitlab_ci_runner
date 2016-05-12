

class{'gitlab_ci_multi_runner':
  admin_email => 'corey@logicminds.biz',
  runner_instances => {
    'user241' => {'instance_parameters' => {}},
    },
  default_ci_token => '112121212'
}
