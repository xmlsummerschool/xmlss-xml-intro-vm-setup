###
# Puppet Script for installing the Course Exercises on Ubuntu 24.04
###

$exercises_url = 'https://static.evolvedbinary.com/xmlss/Hands-on-Introduction-to-XML.zip'
$exercises_install_path = "/home/${default_user}/Desktop/Hands-on Introduction"

file { $exercises_install_path:
  ensure  => directory,
  require => File['default_user_desktop_folder'],
}

exec { 'download-exercises-zip':
  command => "/usr/bin/curl -L ${exercises_url} -o /tmp/Exercises.zip",
  creates => "${exercises_install_path}/Exercises",
  require => [
    Package['curl'],
    File[$exercises_install_path]
  ],
}

exec { 'install-exercises':
  command => "/usr/bin/unzip -o /tmp/Exercises.zip -d /home/${default_user}/Desktop",
  creates => "${exercises_install_path}/Exercises",
  require => [
    Package['zip'],
    Exec['download-exercises-zip'],
  ],
}
