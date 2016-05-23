require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::homebrewdir}/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx
  include vagrant
  include vagrant_manager
  include sublime_text
  # include docker
  include teamviewer
  include hipchat
  include mongodb

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  nodejs::version { '0.8': }
  nodejs::version { '0.10': }
  nodejs::version { '0.12': }
  # nodejs::global { '0.12': }

  class { 'nodejs::global':
    version => '0.12'
  }

  # default ruby versions
  ruby::version { '1.9.3': }
  ruby::version { '2.0.0': }
  ruby::version { '2.1.8': }
  ruby::version { '2.2.4': }

  # docker::compose::version { '1.11.1': }
  # class { 'docker':
  #   compose::version => '1.11.1'
  #   # compose => {
  #   #   version => '1.11.1'
  #   # }
  # }

  package { 'docker':
    ensure => present
  }

  package { 'ansible':
    ensure => present
  }
  
  package { 'homebrew/php/composer':
    ensure => present
  }

  package { 'packer':
    ensure => present
  }
  
  package { 'transmission': provider => 'brewcask' }
  package { 'sonos': provider => 'brewcask' }
  package { 'vlc': provider => 'brewcask' }
  package { 'serviio': provider => 'brewcask' }
  package { 'flowsync': provider => 'brewcask' }
  package { 'paintbrush': provider => 'brewcask' }
  package { 'google-chrome': provider => 'brewcask' }


  class { 'virtualbox':
    version     => '5.0.14',
    patch_level => '105127'
  }

  # sublime_text::package { 'Emmet':
  #   source => 'sergeche/emmet-sublime'
  # }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }
}
