###
# Puppet Script for Modelio on Ubuntu 24.04
###

$modelio_version = '5.4.1'

exec { 'download-modelio-deb':
  command => "/usr/bin/curl -L https://github.com/ModelioOpenSource/Modelio/releases/download/v${modelio_version}/modelio-open-source-${modelio_version}_amd64.deb -o /tmp/modelio.deb",
  unless  => '/usr/bin/dpkg -s modelio',
  require => Package['curl'],
}

package { 'modelio':
  ensure  => installed,
  source  => '/tmp/modelio.deb',
  require => [
    Package['desktop'],
    Exec['download-modelio-deb'],
  ],
}

file { 'modelio-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/modelio.desktop",
  source  => '/usr/share/applications/modelio.desktop',
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    Package['modelio'],
  ],
}

exec { 'gvfs-trust-vscode-desktop-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/modelio.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/modelio.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['modelio-desktop-shortcut'],
}
