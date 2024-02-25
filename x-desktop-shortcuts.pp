###
# Puppet Script for extra Desktop Shortcuts on Ubuntu 22.04
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

exec { 'download-existdb-x-logo':
  command => "wget -O /home/${default_user}/.local/share/icons/existdb-x.png https://raw.githubusercontent.com/eXist-db/exist/develop/exist-core/src/main/resources/org/exist/client/icons/x.png",
  path    => '/usr/bin',
  creates => "/home/${default_user}/.local/share/icons/existdb-x.png",
  user    => $default_user,
  require => [
    File['local-icons'],
    Package['wget'],
  ],
}

$existdb_desktop_shortcut =  @("EXISTDB_SHORTCUT_EOF"/L)
  [Desktop Entry]
  Version=1.0
  Name=eXist-db Dashboard
  Exec=/usr/bin/google-chrome-stable http://localhost:8080
  StartupNotify=true
  Terminal=false
  Icon=/home/${default_user}/.local/share/icons/existdb-x.png
  Type=Application
  | EXISTDB_SHORTCUT_EOF

file { 'existdb-dashboard-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/existdb-dashboard.desktop",
  content => $existdb_desktop_shortcut,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    Service['existdb'],
    Exec['install-google-chrome-deb'],
    Exec['download-existdb-x-logo'],
  ],
}

exec { 'gvfs-trust-existdb-dashboard-desktop-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/existdb-dashboard.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/existdb-dashboard.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['existdb-dashboard-desktop-shortcut'],
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

$training_course_desktop_shortcut =  @("TRAINING_COURSE_SHORTCUT_EOF"/L)
  [Desktop Entry]
  Version=1.0
  Name=The Complete XML Developer - Slides
  Exec=/usr/bin/google-chrome-stable https://static.evolvedbinary.com/cxd/
  StartupNotify=true
  Terminal=false
  Icon=/home/${default_user}/.local/share/icons/eb-favicon-logo.svg
  Type=Application
  | TRAINING_COURSE_SHORTCUT_EOF

file { 'training-course-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/training-course.desktop",
  content => $training_course_desktop_shortcut,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    Exec['install-google-chrome-deb'],
    Exec['download-eb-favicon-logo'],
  ],
}

exec { 'gvfs-trust-training-course-desktop-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/training-course.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/training-course.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['training-course-desktop-shortcut'],
}
