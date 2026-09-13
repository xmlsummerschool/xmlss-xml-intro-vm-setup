###
# Puppet Script for MySQL Workbench on Ubuntu
###

$mysql_apt_config_version = '0.8.29-1_all'

https://dev.mysql.com/get/mysql-apt-config_0.8.29-1_all.deb

exec { 'download-mysql-apt-config-deb':
  command => "/usr/bin/curl -L https://dev.mysql.com/get/mysql-apt-config_${mysql_apt_config_version}.deb -o /tmp/mysql-apt-config_${mysql_apt_config_version}.deb",
  unless  => '/usr/bin/dpkg -s mysql-apt-config',
  require => Package['curl'],
}

package { 'mysql-apt-config':
  ensure  => installed,
  source  => "/tmp/mysql-apt-config_${mysql_apt_config_version}.deb",
  require => [
    Package['desktop'],
    Exec['download-mysql-apt-config-deb'],
  ],
}

package { 'mysql-workbench-community':
  ensure  => installed,
  require => Package['mysql-apt-config'],
}

xdesktop::shortcut { 'MySQL Workbench':
  shortcut_source => '/usr/share/applications/mysql-workbench.desktop',
  user            => $default_user,
  position        => {
    provider => 'lxqt',
    x        => 266,
    y        => 138,
  },
  require         => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File['desktop-items-0'],
    Package['mysql-workbench-community'],
  ],
}
