###
# Puppet Script for Quercus (PHP) on Ubuntu 24.04
#
# See: http://quercus.caucho.com/
###

$quercus_version = '4.0.39'
$quercus_war_path = '/opt/tomcat/webapps/phpService.war'

exec { 'download-quercus':
  command => "curl -L http://caucho.com/download/quercus-${quercus_version}.war -o ${quercus_war_path}",
  path    => '/usr/bin',
  user    => 'tomcat',
  group   => 'tomcat',
  creates => $quercus_war_path,
  require => [
    Package['file'],
    Package['curl'],
    Service['tomcat']
  ],
} ~> exec { 'set-phpService-mode':
  command => 'chmod 770 /opt/tomcat/webapps/phpService',
  onlyif  => 'test -f /opt/tomcat/webapps/phpService/index.php',
  path    => '/usr/bin',
}
