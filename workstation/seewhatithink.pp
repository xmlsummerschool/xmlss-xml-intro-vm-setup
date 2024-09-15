###
# Puppet Script for seewhatithink app on Ubuntu 24.04
###

$seewhatithink_war_path = '/opt/tomcat/webapps/seewhatithink.war'
$sqlwebservices_war_path = '/opt/tomcat/webapps/sqlWebServices.war'

$firefox_profile_id = 'ki59z67a'

exec { 'download-printer-sql':
  command  => '/usr/bin/curl -L https://static.evolvedbinary.com/xmlss/create-xmlss_printer.sql -o /tmp/create-xmlss_printer.sql',
  unless   => "/usr/bin/mysqlshow -u root --password=${mariadb_db_root_password} | /usr/bin/grep xmlss_printer",
  provider => shell,
  require  => [
    Package['curl'],
    Service['mariadb'],
  ],
}

exec { 'create-printer-db':
  command  => "/usr/bin/cat /tmp/create-xmlss_printer.sql | /usr/bin/mysql -u root --password=${mariadb_db_root_password}",
  unless   => "/usr/bin/mysqlshow -u root --password=${mariadb_db_root_password} | /usr/bin/grep xmlss_printer",
  provider => shell,
  require  => [
    Exec['download-printer-sql'],
    Service['mariadb'],
  ],
}

exec { 'download-seewhatithink':
  command => "curl -L https://static.evolvedbinary.com/xmlss/seewhatithink.war -o ${seewhatithink_war_path}",
  path    => '/usr/bin',
  user    => 'tomcat',
  group   => 'tomcat',
  creates => $seewhatithink_war_path,
  require => [
    Package['file'],
    Package['curl'],
    Service['tomcat']
  ],
}

exec { 'download-sqlwebservices':
  command => "curl -L https://static.evolvedbinary.com/xmlss/sqlWebServices.war -o ${sqlwebservices_war_path}",
  path    => '/usr/bin',
  user    => 'tomcat',
  group   => 'tomcat',
  creates => $sqlwebservices_war_path,
  require => [
    Package['file'],
    Package['curl'],
    Service['tomcat']
  ],
}

# Set homepage for seewhatithink.com

file { "/home/${default_user}/snap":
  ensure => directory,
  owner  => $default_user,
  group  => $default_user,
  mode   => '0700',
}

file { "/home/${default_user}/snap/firefox":
  ensure  => directory,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0755',
  require => File["/home/${default_user}/snap"],
}

file { "/home/${default_user}/snap/firefox/common":
  ensure  => directory,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0755',
  require => File["/home/${default_user}/snap/firefox"],
}

file { "/home/${default_user}/snap/firefox/common/.mozilla":
  ensure  => directory,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0700',
  require => File["/home/${default_user}/snap/firefox/common"],
}

file { "/home/${default_user}/snap/firefox/common/.mozilla/firefox":
  ensure  => directory,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0700',
  require => File["/home/${default_user}/snap/firefox/common/.mozilla"],
}

file { "/home/${default_user}/snap/firefox/common/.mozilla/firefox/profiles.ini":
  ensure  => file,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0664',
  content => "[Profile0]
Name=default
IsRelative=1
Path=${firefox_profile_id}.default
Default=1

[General]
StartWithLastProfile=1
Version=2",
  require => [
    File["/home/${default_user}/snap/firefox/common/.mozilla/firefox"],
    Exec['download-seewhatithink'],
    Package['firefox'],
  ],
}

file { "/home/${default_user}/snap/firefox/common/.mozilla/firefox/${firefox_profile_id}.default":
  ensure  => directory,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0700',
  require => File["/home/${default_user}/snap/firefox/common/.mozilla/firefox"],
}

file { "/home/${default_user}/snap/firefox/common/.mozilla/firefox/${firefox_profile_id}.default/prefs.js":
  ensure  => file,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0600',
  require => File["/home/${default_user}/snap/firefox/common/.mozilla/firefox/${firefox_profile_id}.default"],
}

file_line { 'firefox-home-page':
  ensure  => present,
  path    => "/home/${default_user}/snap/firefox/common/.mozilla/firefox/${firefox_profile_id}.default/prefs.js",
  line    => 'user_pref("browser.startup.homepage", "http://localhost:8080/seewhatithink");',
  match   => '^user_pref\("browser\.startup\.homepage"',
  require => [
    File["/home/${default_user}/snap/firefox/common/.mozilla/firefox/${firefox_profile_id}.default/prefs.js"],
    Exec['download-seewhatithink'],
    Package['firefox'],
  ],
}
