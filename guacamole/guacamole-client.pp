###
# Puppet Script to build and install Guacamole Client on Ubuntu 24.04
###

$guacamole_client_source_folder = "/home/${default_user}/code/guacamole-client"

file { 'guacamole-client-source-folder':
  ensure  => directory,
  path    => $guacamole_client_source_folder,
  replace => false,
  owner   => $default_user,
  group   => $default_user,
  require => File['default_user_code_folder'],
}

vcsrepo { 'guacamole-client-source':
  ensure             => latest,
  path               => $guacamole_client_source_folder,
  provider           => git,
  source             => 'https://github.com/apache/guacamole-client.git',
  revision           => 'main',
  keep_local_changes => false,  # TODO(AR) change this to 'true' once https://github.com/puppetlabs/puppetlabs-vcsrepo/pull/623 is merged and released
  owner              => $default_user,
  group              => $default_user,
  require            => [
    Package['git'],
    File['guacamole-client-source-folder'],
  ],
}

exec { 'guacamole-client-compile':
  cwd      => $guacamole_client_source_folder,
  command  => '/opt/maven/bin/mvn package',
  provider => shell,
  user     => $default_user,
  creates  => "${guacamole_client_source_folder}/target",
  require  => [
    Vcsrepo['guacamole-client-source'],
    Package['openjdk-17-jdk-headless'],
    File['/opt/maven'],
  ],
}

file { '/etc/guacamole':
  ensure  => directory,
  replace => false,
  owner   => 'root',
  group   => 'root',
  mode    => '0755',
}

file { '/etc/guacamole/lib':
  ensure  => directory,
  replace => false,
  owner   => 'root',
  group   => 'root',
  mode    => '0755',
  require => File['/etc/guacamole'],
}

file { '/etc/guacamole/extensions':
  ensure  => directory,
  replace => false,
  owner   => 'root',
  group   => 'root',
  mode    => '0755',
  require => File['/etc/guacamole'],
}

$guacamole_properties = @("GUACAMOLE_PROPERTIES_EOF"/L)
  allowed-languages: en
  guacd-hostname: localhost
  guacd-port: 4822
  | GUACAMOLE_PROPERTIES_EOF

file { '/etc/guacamole/guacamole.properties':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => '0744',
  content => $guacamole_properties,
  require => File['/etc/guacamole'],
}

$user_mapping = @("USER_MAPPING_EOF":xml/L)
  <user-mapping>
      <authorize username="xmlss1" password="xmlss">
          <connection name="xmlss1">
              <protocol>rdp</protocol>
              <param name="hostname">xmlss1.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${xmlss_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
      </authorize>
      <authorize username="xmlss2" password="xmlss">
          <connection name="xmlss2">
              <protocol>rdp</protocol>
              <param name="hostname">xmlss2.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${xmlss_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
      </authorize>
      <authorize username="xmlss3" password="xmlss">
          <connection name="xmlss3">
              <protocol>rdp</protocol>
              <param name="hostname">xmlss3.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${xmlss_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
      </authorize>
      <authorize username="xmlss4" password="xmlss">
          <connection name="xmlss4">
              <protocol>rdp</protocol>
              <param name="hostname">xmlss4.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${xmlss_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
      </authorize>
      <authorize username="xmlss5" password="xmlss">
          <connection name="xmlss5">
              <protocol>rdp</protocol>
              <param name="hostname">xmlss5.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${xmlss_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
      </authorize>
      <authorize username="xmlss6" password="xmlss">
          <connection name="xmlss6">
              <protocol>rdp</protocol>
              <param name="hostname">xmlss6.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${xmlss_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
        </authorize>
        <authorize username="xmlss7" password="xmlss">
          <connection name="xmlss7">
              <protocol>rdp</protocol>
              <param name="hostname">xmlss7.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${xmlss_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
        </authorize>
        <authorize username="xmlss8" password="xmlss">
          <connection name="xmlss8">
              <protocol>rdp</protocol>
              <param name="hostname">xmlss8.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${xmlss_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
      </authorize>
      <authorize username="xmlss9" password="xmlss">
          <connection name="xmlss9">
              <protocol>rdp</protocol>
              <param name="hostname">xmlss9.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${xmlss_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
      </authorize>
      <authorize username="xmlss10" password="xmlss">
          <connection name="xmlss10">
              <protocol>rdp</protocol>
              <param name="hostname">xmlss10.evolvedbinary.com</param>
              <param name="port">3389</param>
              <param name="username">ubuntu</param>
              <param name="password">${xmlss_default_user_password}</param>
              <param name="enable-touch">false</param>
              <param name="resize-method">display-update</param>
              <param name="disable-audio">true</param>
              <param name="enable-printing">true</param>
              <param name="printer-name">guacamole-client</param>
              <param name="enable-drive">true</param>
              <param name="drive-name">guacamole</param>
              <param name="drive-path">/guacamole-drive</param>
          </connection>
      </authorize>
  </user-mapping>
  | USER_MAPPING_EOF

file { '/etc/guacamole/user-mapping.xml':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => '0744',
  content => $user_mapping,
  require => File['/etc/guacamole'],
}

file { 'guacamole-war':
  ensure  => file,
  path    => '/opt/tomcat/webapps/guacamole.war',
  source  => "${guacamole_client_source_folder}/guacamole/target/guacamole-1.6.0.war",
  require => [
    File['/etc/guacamole/guacamole.properties'],
    File['/etc/guacamole/user-mapping.xml'],
    File['/etc/guacamole/lib'],
    File['/etc/guacamole/extensions'],
    Exec['guacamole-client-compile'],
    Service['tomcat'],
  ],
}
