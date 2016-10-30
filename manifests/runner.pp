# == Define: gitlab_ci_multi_runner::runner
#
# Define for creating a gitlab-ci runner.
#
# gitlab_ci_multi_runner can/should be included to install
# gitlab-ci-multi-runner if needed.
#
# === Parameters
#
# [*docker_host]

# [*gitlab_ci_url*]
#   URL of the Gitlab Server.
#   Default: undef.
#
# [*tags*]
#   Array of tags.
#   Default: undef.
#
# [*token*]
#   CI Token.
#   Default: undef.
#
# [*env*]
#   Custom environment variables injected to build environment.
#   Default: undef.
#
# [*executor*]
#   Executor - Shell, parallels, ssh, docker etc.
#   Default: undef.
#
# [*docker_image*]
#   The Docker Image (eg. ruby:2.1).
#   Default: undef.
#
# [*docker_privileged*]
#   Run Docker containers in privileged mode.
#   Default: undef.
#
# [*docker_mysql*]
#   MySQL version (X.Y) or latest.
#   Default: undef.
#
# [*docker_postgres*]
#   Postgres version (X.Y) or latest.
#   Default: undef.
#
# [*docker_redis*]
#   Redis version (X.Y) or latest.
#   Default: undef.
#
# [*docker_mongo*]
#   Mongo version (X.Y) or latest.
#   Default: undef.
#
# [*docker_allowed_images*]
#   Array of wildcard list of images that can be specified in .gitlab-ci.yml
#   Default: undef.
#
# [*docker_allowed_services*]
#   Array of wildcard list of services that can be specified in .gitlab-ci.yml
#   Default: undef.
#
# [*parallels_vm*]
#   The Parallels VM (eg. my-vm).
#   Default: undef.
#
# [*ssh_host*]
#   The SSH Server Address.
#   Default: undef.
#
# [*ssh_port*]
#   The SSH Server Port.
#   Default: undef.
#
# [*ssh_user*]
#   The SSH User.
#   Default: undef.
#
# [*ssh_password*]
#   The SSH Password.
#   Default: undef.
#
# [*require*]
#   Array of requirements for the runner registration resource.
#   Default: [ Class['gitlab_ci_multi_runner'] ].
#
# === Examples
#
#  gitlab_ci_multi_runner::runner { "This is My Runner":
#      gitlab_ci_url => 'http://ci.gitlab.examplecorp.com'
#      tags          => ['tag', 'tag2','java', 'php'],
#      token         => 'sometoken'
#      executor      => 'shell',
#  }
#
#  gitlab_ci_multi_runner::runner { "This is My Second Runner":
#      gitlab_ci_url => 'http://ci.gitlab.examplecorp.com'
#      tags          => ['tag', 'tag2','npm', 'grunt'],
#      token         => 'sometoken'
#      executor      => 'ssh',
#      ssh_host      => 'cirunners.examplecorp.com'
#      ssh_port      => 22
#      ssh_user      => 'mister-ci'
#      ssh_password  => 'password123'
#  }
#
define gitlab_ci_multi_runner::runner (
    ########################################################
    # Runner Options                                       #
    # Used By all Executors.                               #
    ########################################################
    $user,
    $toml_file = '/etc/gitlab/gitlab-runner/config.toml',
    $gitlab_ci_url = undef,
    $tags = undef,
    $token = undef,
    $env = undef,
    $executor = undef,
    Optional[Hash] $docker_volumes,
    ########################################################
    # Docker Options                                       #
    # Used by the Docker and Docker SSH executors.         #
    ########################################################

    $docker_image = undef,
    $docker_privileged = undef,
    $docker_services = undef,
    $docker_allowed_images = undef,
    $docker_allowed_services = undef,
    $concurrency         = hiera('gitlab_ci_multi_runner::concurrency', '3'),
    ########################################################
    # Parallels Options                                    #
    # Used by the "Parallels" executor.                    #
    ########################################################

    $parallels_vm = undef,

    ########################################################
    # SSH Options                                          #
    # Used by the SSH, Docker SSH, and Parllels Executors. #
    ########################################################

    $ssh_host = undef,
    $ssh_port = undef,
    $ssh_user = undef,
    $ssh_password = undef,
) {
    # GitLab allows runner names with problematic characters like quotes
    # Make sure they don't trip up the shell when executed
    $description = shellquote($name)
    $group = $user
    $home_path = "/home/${user}"


    # Here begins the arduous, manual process of taking each argument
    # and turning it into option strings.
    # TODO find a better way to read this.

    if $gitlab_ci_url {
        $gitlab_ci_url_opt = "--url=${gitlab_ci_url}"
    }

    if $description {
        $description_opt = "--name=${description}"
    }

    if $tags {
        $tagstr = join($tags,',')
        $tags_opt = "--tag-list=${tagstr}"
    }

    if $token {
        $token_opt = "--registration-token=${token}"
    }

    if $env {
        $envarry = prefix(any2array($env),'--env=')
        $env_opts = join($envarry,' ')
    }

    # I group like arguments together so my final opstring won't be so giant.
    $runner_opts = "${gitlab_ci_url_opt} ${description_opt} ${tags_opt} ${token_opt} ${env_opts}"

    if $executor {
        $executor_opt = "--executor=${executor}"
    }

    if $docker_image {
        $docker_image_opt = "--docker-image=${docker_image}"
    }

    if $docker_privileged {
        $docker_privileged_opt = '--docker-privileged'
    }

    if $docker_services {
        $docker_services_opt = "--docker-mysql=${docker_mysql}"
    }

    if $docker_allowed_images {
        $docker_allowed_images_opt = $docker_allowed_images.map | String $image | {
          "--docker-allowed-images=\"${image}\""
        }

    }
    if $docker_allowed_services {
      $docker_allowed_services_opt = $docker_allowed_services.map | String $service | {
        "--docker-allowed-services=\"${service}\""
      }
    }


    if $docker_volumes {
      $docker_volumes_opt = $docker_volumes.map | $k, $v | { "$k:$v" }
    } else {
      $docker_volumes_opt = ''
    }

    $docker_opts = "${docker_image_opt} ${docker_privileged_opt} ${docker_allowed_images_opt.join(' ')} ${docker_allowed_services_opt.join(' ')}"

    if $parallels_vm {
      $parallels_vm_opt = "--parallels-vm=${parallels_vm}"
    }

    if $ssh_host {
        $ssh_host_opt = "--ssh-host=${ssh_host}"
    }

    if $ssh_port {
        $ssh_port_opt = "--ssh-port=${ssh_port}"
    }

    if $ssh_user {
        $ssh_user_opt = "--ssh-user=${ssh_user}"
    }

    if $ssh_password {
        $ssh_password_opt = "--ssh-password=${ssh_password}"
    }

    $ssh_opts = "${ssh_host_opt} ${ssh_port_opt} ${ssh_user_opt} ${ssh_password_opt}"

    $opts = "${runner_opts} ${executor_opt} ${docker_opts} ${parallels_vm_opt} ${ssh_opts}"

    file{$toml_file:
        ensure => file,
        owner  => $user,
        group  => $user,
        mode   => '0640',
        before => Exec["Register-${name}"]
    }

    # Register a new runner - this is where the magic happens.
    # Only if the config.toml file doesn't already contain an entry.
    # --non-interactive means it won't ask us for things, it'll just fail out.
    exec { "Register-${name}":
        command     => "gitlab-ci-multi-runner register --non-interactive ${opts}",
        user        => $user,
        path        => [$home_path, '/bin', '/usr/bin', '/usr/local/bin'],
        environment => ["HOME=${home_path}", "DOCKER_VOLUMES=${docker_volumes_opt}"],
        provider    => shell,
        cwd         => $home_path,
        refreshonly => true,
    }
    unless defined(Ini_setting['concurrency']) {
        ini_setting { "concurrency":
          ensure  => present,
          path    => $toml_file,
          setting => 'concurrent',
          value   => $concurrency,
          require => Exec["Register-${name}"],
        }
    }
    unless defined(Ini_setting['options_checksum']) {
        ini_setting { "options_checksum":
          ensure  => present,
          path    => $toml_file,
          setting => 'options_checksum',
          value   => sha1($opts),
          require => File[$toml_file],
          notify  => Exec["Register-${name}"]
        }
     }
}
