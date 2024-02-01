###
# Puppet Script for VSCode on Ubuntu 22.04
###

exec { 'download-vscode-deb':
  command => '/usr/bin/curl -L https://update.code.visualstudio.com/latest/linux-deb-x64/stable -o /tmp/vscode.deb',
  unless  => '/usr/bin/dpkg -s code',
  require => Package['curl'],
}

exec { 'install-vscode-deb':
  command => '/usr/bin/dpkg -i /tmp/vscode.deb',
  unless  => '/usr/bin/dpkg -s code',
  user    => 'root',
  require => [
    Package['desktop'],
    Exec['download-vscode-deb'],
  ],
}

file_line { 'vscode-no-open-folder':
  ensure  => present,
  path    => '/usr/share/applications/code.desktop',
  line    => 'MimeType=text/plain;application/x-code-workspace;',
  match   => '^MimeType\=',
  require => Exec['install-vscode-deb'],
}

file { 'vscode-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/code.desktop",
  source  => '/usr/share/applications/code.desktop',
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File_line['vscode-no-open-folder'],
  ],
}

exec { 'gvfs-trust-vscode-desktop-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/code.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/code.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['vscode-desktop-shortcut'],
}
