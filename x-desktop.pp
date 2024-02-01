###
# Puppet Script for a Desktop Developer Environment using LXQT on Ubuntu 22.04
###

file { 'disable-screensaver':
  ensure  => file,
  path    => "/home/${default_user}/.xscreensaver",
  replace => false,
  mode    => '0664',
  content => 'mode:    off',
}

file_line { 'disable-screensaver':
  ensure  => present,
  path    => "/home/${default_user}/.xscreensaver",
  line    => 'mode:    off',
  match   => '^mode:',
  require => File['disable-screensaver'],
}

package { 'desktop':
  ensure  => installed,
  name    => 'lubuntu-desktop',
  require => File_line['disable-screensaver'],
}

file { 'default_user_desktop_folder':
  ensure  => directory,
  path    => "/home/${default_user}/Desktop",
  replace => false,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0775',
  require => [
    Package['desktop'],
    File['default_user_home'],
  ],
}

file { 'qterminal-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/qterminal.desktop",
  source  => '/usr/share/applications/qterminal.desktop',
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
  ],
}

exec { 'gvfs-trust-qterminal-desktop-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/qterminal.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/qterminal.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['qterminal-desktop-shortcut'],
}

file_line { 'simplify-pcmanfm-qt-name':
  ensure  => present,
  path    => '/usr/share/applications/pcmanfm-qt.desktop',
  line    => 'Name=File Manager',
  match   => '^Name\=',
  require => Package['desktop'],
}

file { 'pcmanfm-qt-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/pcmanfm-qt.desktop",
  source  => '/usr/share/applications/pcmanfm-qt.desktop',
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File_line['simplify-pcmanfm-qt-name'],
  ],
}

exec { 'gvfs-trust-pcmanfm-qt-desktop-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/pcmanfm-qt.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/pcmanfm-qt.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['pcmanfm-qt-desktop-shortcut'],
}
