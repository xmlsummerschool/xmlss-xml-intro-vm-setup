$oxygen_version = '26.0'

file { "/opt/oxygen-${oxygen_version}":
  ensure  => directory,
  replace => false,
  owner   => 'root',
  group   => 'root',
}

exec { 'install-oxygen':
  command => "curl https://mirror.oxygenxml.com/InstData/Editor/All/oxygen.tar.gz | tar zxv -C /opt/oxygen-${oxygen_version} --strip-components=1",
  path    => '/usr/bin',
  user    => 'root',
  creates => "/opt/oxygen-${oxygen_version}/oxygen.sh",
  require => [
    File["/opt/oxygen-${oxygen_version}"],
    Package['curl']
  ],
}

file { '/opt/oxygen':
  ensure  => link,
  target  => "/opt/oxygen-${oxygen_version}",
  replace => false,
  owner   => 'root',
  group   => 'root',
  require => File["/opt/oxygen-${oxygen_version}"],
}

file { 'oxygen-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/oxygen.desktop",
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  content => "[Desktop Entry]
Version=1.0
Type=Application
Name=Oxygen XML Editor
Exec=/opt/oxygen/oxygen.sh
Icon=/opt/oxygen/Oxygen128.png
Terminal=false
StartupNotify=false
GenericName=Oxygen XML Editor
",
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File['/opt/oxygen']
  ],
}

exec { 'gvfs-trust-oxygen-desktop-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/oxygen.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/oxygen.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['oxygen-desktop-shortcut'],
}
