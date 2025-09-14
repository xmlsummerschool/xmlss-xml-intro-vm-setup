###
# Puppet Script for cityEHR on Ubuntu 24.04
###

$cityehr_version = '1.8.0-SNAPSHOT'
$cityehr_war_url = "https://openhealthinformatics.com/wp-content/resources/cityehr-webapp-${cityehr_version}.war"
#$cityehr_war_url = 'https://openhealthinformatics.com/wp-content/resources/cityehr.war'
$cityehr_war_path = '/opt/tomcat/webapps/cityehr.war'
$cityehr_quickstart = '2024-08-05_cityEHR_QuickStart.pdf'

exec { 'download-cityehr':
  command => "curl -L ${cityehr_war_url} -o ${cityehr_war_path}",
  path    => '/usr/bin',
  user    => 'tomcat',
  group   => 'tomcat',
  creates => $cityehr_war_path,
  require => [
    Package['file'],
    Package['curl'],
    Service['tomcat']
  ],
}

# Add a Desktop Shortcut to the cityEHR Documentation
exec { 'download-cityehr-logo':
  command => "wget -O /home/${default_user}/.local/share/icons/cityehr-logo.png https://cityehr.github.io/cityehr-documentation/images/cityehr-logo.png",
  path    => '/usr/bin',
  creates => "/home/${default_user}/.local/share/icons/cityehr-logo.png",
  user    => $default_user,
  require => [
    File['local-icons'],
    Package['wget'],
  ],
}

xdesktop::shortcut { 'cityEHR Documentation':
  application_path => '/usr/bin/google-chrome-stable https://cityehr.github.io/cityehr-documentation/',
  application_icon => "/home/${default_user}/.local/share/icons/cityehr-logo.png",
  startup_notify   => true,
  user             => $default_user,
  position         => {
    provider => 'lxqt',
    x        => 393,
    y        => 12,
  },
  require          => [
    Package['desktop'],
    Package['google-chrome-stable'],
    File['default_user_desktop_folder'],
    File['desktop-items-0'],
    Exec['download-cityehr-logo'],
  ],
}
