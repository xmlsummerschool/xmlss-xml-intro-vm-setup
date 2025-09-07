###
# Puppet Script for oXygen XML Editor on Ubuntu 24.04
###

$oxygen_version = '27.1'

$oxygen_license_xml = @(OXYGEN_LICENSE_XML_EOF:xml/L)
  <?xml version="1.0" encoding="UTF-8"?>
  <serialized xml:space="preserve">
    <serializableOrderedMap>
      <entry>
        <String>license.26</String>
        <String>------START-LICENSE-KEY------

Registration_Name=adam @ exist-db . org

Company=eXist-db-Open-Source-Project

Category=Enterprise

Component=XML-Editor, XSLT-Debugger, Saxon-SA

Version=27

Number_of_Licenses=1

Date=09-07-2025

Trial=30

SGN=MCwCFFbvNx62V/fUy0LBcDPImMCJQOSJAhQQ6gAbwB+YcL0lfsn/cluExNmR6g\=\=

-------END-LICENSE-KEY-------</String>
      </entry>
    </serializableOrderedMap>
  </serialized>
  | OXYGEN_LICENSE_XML_EOF

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

xdesktop::shortcut { 'Oxygen XML Editor':
  application_path => '/opt/oxygen/oxygen.sh',
  application_icon => '/opt/oxygen/Oxygen128.png',
  user             => $default_user,
  position         => {
    provider => 'lxqt',
    x        => 139,
    y        => 642,
  },
  require          => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File['desktop-items-0'],
    File['/opt/oxygen'],
  ],
}

# oXygen License file
file { 'oxygen-user-settings-path':
  ensure  => directory,
  path    => "/home/${default_user}/.com.oxygenxml",
  replace => false,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0775',
}

file { 'oxygen-license':
  ensure  => file,
  path    => "/home/${default_user}/.com.oxygenxml/license.xml",
  replace => false,
  owner   => $default_user,
  group   => $default_user,
  mode    => '0664',
  content => $oxygen_license_xml,
  require => File['oxygen-user-settings-path'],
}
