class osx_config::system {

  boxen::osx_defaults {
    'Increase cursor speed':
      ensure => present,
      key    => 'KeyRepeat',
      domain => 'NSGlobalDomain',
      value  => '0',
      type   => 'int',
      user   => $::boxen_user;
  }

}