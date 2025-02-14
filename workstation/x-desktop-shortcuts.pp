###
# Puppet Script for extra Desktop Shortcuts on Ubuntu 24.04
###

file { 'dot-local':
  ensure  => directory,
  path    => "/home/${default_user}/.local",
  owner   => $default_user,
  group   => $default_user,
  mode    => '0700',
  require => Package['desktop'],
}

file { 'dot-local-share':
  ensure  => directory,
  path    => "/home/${default_user}/.local/share",
  owner   => $default_user,
  group   => $default_user,
  mode    => '0700',
  require => [
    Package['desktop'],
    File['dot-local'],
  ],
}

file { 'local-icons':
  ensure  => directory,
  path    => "/home/${default_user}/.local/share/icons",
  owner   => $default_user,
  group   => $default_user,
  mode    => '0755',
  require => [
    Package['desktop'],
    File['dot-local-share'],
  ],
}

exec { 'download-eb-favicon-logo':
  command => "wget -O /home/${default_user}/.local/share/icons/eb-favicon-logo.svg https://evolvedbinary.com/images/icons/shape-icon.svg",
  path    => '/usr/bin',
  creates => "/home/${default_user}/.local/share/icons/eb-favicon-logo.svg",
  user    => $default_user,
  require => [
    File['local-icons'],
    Package['wget'],
  ],
}

xdesktop::shortcut { 'Evolved Binary':
  application_path => '/usr/bin/google-chrome-stable https://www.evolvedbinary.com',
  application_icon => "/home/${default_user}/.local/share/icons/eb-favicon-logo.svg",
  startup_notify   => true,
  user             => $default_user,
  position         => {
    provider => 'lxqt',
    x        => 393,
    y        => 264,
  },
  require          => [
    Package['desktop'],
    Package['google-chrome-stable'],
    File['default_user_desktop_folder'],
    File['desktop-items-0'],
    Exec['download-eb-favicon-logo'],
  ],
}

exec { 'download-ohi-logo':
  command => "wget -O /home/${default_user}/.local/share/icons/ohi-logo.png https://openhealthinformatics.com/wp-content/uploads/2024/05/cropped-logo-150x150.png",
  path    => '/usr/bin',
  creates => "/home/${default_user}/.local/share/icons/ohi-logo.png",
  user    => $default_user,
  require => [
    File['local-icons'],
    Package['wget'],
  ],
}

xdesktop::shortcut { 'Open Health Informatics':
  application_path => '/usr/bin/google-chrome-stable https://openhealthinformatics.com',
  application_icon => "/home/${default_user}/.local/share/icons/ohi-logo.png",
  startup_notify   => true,
  user             => $default_user,
  position         => {
    provider => 'lxqt',
    x        => 393,
    y        => 138,
  },
  require          => [
    Package['desktop'],
    Package['google-chrome-stable'],
    File['default_user_desktop_folder'],
    File['desktop-items-0'],
    Exec['download-ohi-logo'],
  ],
}

xdesktop::shortcut { 'Exercises':
  application_path => '/usr/bin/google-chrome-stable https://drive.google.com/drive/u/1/folders/1kDva2n1aVIhzcCzhpyOlwaCu0Q11NgOC',
  application_icon => "/usr/share/icons/Adwaita/symbolic/places/folder-remote-symbolic.svg",
  startup_notify   => true,
  user             => $default_user,
  position         => {
    provider => 'lxqt',
    x        => 393,
    y        => 516,
  },
  require          => [
    Package['desktop'],
    Package['google-chrome-stable'],
    File['default_user_desktop_folder'],
    File['desktop-items-0'],
  ],
}

xdesktop::shortcut { 'Presentations':
  application_path => '/usr/bin/google-chrome-stable https://drive.google.com/drive/u/1/folders/1UGJDHXSCH2aAG4x50jc0ZEqI6UT_3Gi8',
  application_icon => "/usr/share/icons/Adwaita/symbolic/places/folder-remote-symbolic.svg",
  startup_notify   => true,
  user             => $default_user,
  position         => {
    provider => 'lxqt',
    x        => 393,
    y        => 642,
  },
  require          => [
    Package['desktop'],
    Package['google-chrome-stable'],
    File['default_user_desktop_folder'],
    File['desktop-items-0'],
  ],
}

