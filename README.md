Gitlab CI Multi Runner
---
A module for the installation and use of the 
[Gitlab CI MultiRunner](https://github.com/ayufan/gitlab-ci-multi-runner) written in Go.

The module installs the ci runner into the user's home directory and runs everything out of the home
directory under the user.   This module was designed to run multiple instances of the runner under unique users.  
This may be desirable when docker is not available and processes cannot be run under root. 

## Usage
To get started you first need to pass a hash of users. By default you do not need to pass any parameters for each user
if you supply default values with the gitlab_ci_multi_runner class. 

```
default_ci_token => '29idiuoikdihfiijofsdiuhou',
default_download_url => 'https://gitlab.com/ci/download',
default_gitlab_ci_url = 'https://gitlab.com/ci',
default_tags = ['puppet', 'rspec-puppet'],
default_executor = 'shell'
```

Each default is overidden easily by specifing the parameters in the runner or instance parameters. 

class{'gitlab_ci_multi_runner':
  runner_instances => {
    'user231' => {'runner_parameters' => {
        gitlab_ci_url => 'http://ci.gitlab.examplecorp.com'
        tags          => ['tag', 'tag2','npm', 'grunt'],
        token         => 'sometoken'
        executor      => 'ssh',
        ssh_host      => 'cirunners.examplecorp.com'
        ssh_port      => 22
        ssh_user      => 'mister-ci'
        ssh_password  => 'password123'
        }
    }, "instance_parameters" => {
       'download_url => 'https://gitlab.com/ci/download'
    
    }
  },
  default_ci_token => '29idiuoikdihfiijofsdiuhou',
  default_download_url => 'https://gitlab.com/ci/download',
  default_gitlab_ci_url = 'https://gitlab.com/ci',
  default_tags = ['puppet', 'rspec-puppet'],
  default_executor = 'shell'

}

```

##Installation Options

##Runner Options

All options are pulled from the Gitlab CI MultiRunner registration command - The name of the runner
will be used to Generate the description when registering the Runner.

###Standard Options
Used By all Executors.

####gitlab\_ci\_url
> The GitLab-CI Coordinator URL

####tags
This is a list of tags to apply to the runner - it takes an array, which will be joined into a comma
separated list of tags.

####token
> The GitLab-CI Token for this Runner

####executor
> The Executor: shell, docker, docker-ssh, ssh?

The Runner is packages with a "Parallels" Executor as well.

### Docker Options
Used by the Docker and Docker SSH executors.

####docker\_image
> The Docker Image (eg. ruby:2.1)

####docker\_privileged
> Run Docker containers in privileged mode

Any truthy value will set this off.

####docker\_mysql
> If you want to enable mysql please enter version (X.Y) or enter latest

####docker\_postgres
> If you want to enable postgres please enter version (X.Y) or enter latest

####docker\_redis
> If you want to enable redis please enter version (X.Y) or enter latest

####docker\_mongo
> If you want to enable mongo please enter version (X.Y) or enter latest

###Parallels Options
Used by the "Parallels" executor.

####parallels\_vm
> The Parallels VM (eg. my-vm)

###SSH Options
Used by the SSH, Docker SSH, and Parllels Executors.

####ssh\_host
> The SSH Server Address (eg. my.server.com)

####ssh\_port
> The SSH Server Port (eg. 22)

####ssh\_user
> The SSH User (eg. root)

####ssh\_password
> The SSH Password (eg. docker.io)

## Contributing

Please maintain sensible spacing between logical blocks of code, and a 4 space indent - no tabs,
thank you.  Where line breaks are concerned - readability is the key here.  Since we're no longer
using [punch cards](http://programmers.stackexchange.com/questions/148677/why-is-80-characters-the-standard-limit-for-code-width)
to run our code, there's no need for our lines to fit into a specific line length 100% of the time.
That being said, this repository likes to wrap between 80 and 100 characters when possible, to
facilitate a broad range of coding display styles.  If you use 
[puppet-lint](http://puppet-lint.com/), I suggest you also use the flag to disable the 
[80 character line limit](http://puppet-lint.com/checks/80chars/).

Please open pull requests for any features you can, and make sure to update the README for your
features.

## CI config doc
https://gitlab.com/gitlab-org/gitlab-ci-multi-runner/blob/master/docs/configuration/advanced-configuration.md