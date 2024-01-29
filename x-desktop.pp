###
# Puppet Script for a Desktop Developer Environment on Ubuntu 22.04
###

package { 'desktop':
  ensure => installed,
  name   => 'lubuntu-desktop',
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
