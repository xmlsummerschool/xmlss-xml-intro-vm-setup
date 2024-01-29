###
# Puppet Script for Eclipse IDE on Ubuntu 22.04
###

$eclipse_version = '2023-12'

file { "/opt/eclipse-${eclipse_version}":
  ensure  => directory,
  replace => false,
  owner   => 'root',
  group   => 'root',
}

exec { 'install-eclipse':
  command => "curl https://mirror.ibcp.fr/pub/eclipse/technology/epp/downloads/release/${eclipse_version}/R/eclipse-java-${eclipse_version}-R-linux-gtk-x86_64.tar.gz | tar zxv -C /opt/eclipse-${eclipse_version} --strip-components=1",
  path    => '/usr/bin',
  user    => 'root',
  creates => "/opt/eclipse-${eclipse_version}/eclipse",
  require => [
    File["/opt/eclipse-${eclipse_version}"],
    Package['curl']
  ],
}

file { '/opt/eclipse':
  ensure  => link,
  target  => "/opt/eclipse-${eclipse_version}",
  replace => false,
  owner   => 'root',
  group   => 'root',
  require => File["/opt/eclipse-${eclipse_version}"],
}

file { 'eclipse-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/eclipse.desktop",
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  content => "[Desktop Entry]
Version=1.0
Type=Application
Name=Eclipse
Exec=/opt/eclipse/eclipse
Icon=/opt/eclipse/icon.xpm
Terminal=false
StartupNotify=false
GenericName=Eclipse IDE
",
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File['/opt/eclipse'],
  ],
}

exec { 'gvfs-trust-eclipse-desktop-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/eclipse.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/eclipse.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['eclipse-desktop-shortcut'],
}
