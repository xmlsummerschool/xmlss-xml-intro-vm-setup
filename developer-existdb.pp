###
# Puppet Script for an eXist-db Developer Environment on Ubuntu 22.04
###

include ufw

$existdb_source_folder_owner = $default_user
$existdb_source_folder = "/home/${existdb_source_folder_owner}/code/existdb"

$app_mount  = '/opt'
$data_mount = '/data'

$sys_existdb_home = "${app_mount}/existdb"
$sys_existdb_data = "${data_mount}/existdb"
$sys_existdb_user = 'existdb'
$sys_existdb_group = 'existdb'

file { 'existdb_source_folder':
  ensure  => directory,
  path    => $existdb_source_folder,
  replace => false,
  owner   => $existdb_source_folder_owner,
  group   => $existdb_source_folder_owner,
  require => File['default_user_code_folder'],
}

vcsrepo { 'existdb_source':
  ensure             => latest,
  path               => $existdb_source_folder,
  provider           => git,
  source             => 'https://github.com/exist-db/exist.git',
  revision           => 'develop',
  keep_local_changes => false,  # TODO(AR) change this to 'true' once https://github.com/puppetlabs/puppetlabs-vcsrepo/pull/623 is merged and released
  owner              => $existdb_source_folder_owner,
  group              => $existdb_source_folder_owner,
  require            => [
    Package['git'],
    File['existdb_source_folder'],
  ],
}

file { 'existdb_quick_build_script':
  ensure  => file,
  path    => "${existdb_source_folder}/quick-build.sh",
  replace => false,
  owner   => $existdb_source_folder_owner,
  group   => $existdb_source_folder_owner,
  mode    => '0770',
  require => [
    Vcsrepo['existdb_source'],
    File['/opt/maven'],
  ],
  content => "#!/usr/bin/env bash
set -e
/opt/maven/bin/mvn -V -T2C clean package -DskipTests -Ddependency-check.skip=true -Dappbundler.skip=true -Ddocker=false -P !mac-dmg-on-mac,!codesign-mac-app,!codesign-mac-dmg,!mac-dmg-on-unix,!installer,!concurrency-stress-tests,!micro-benchmarks,skip-build-dist-archives",
}

file { 'existdb_quick_install_script':
  ensure  => file,
  path    => "${existdb_source_folder}/quick-install.sh",
  replace => false,
  owner   => $existdb_source_folder_owner,
  group   => $existdb_source_folder_owner,
  mode    => '0770',
  require => [
    Vcsrepo['existdb_source'],
    File['/opt/maven'],
  ],
  content => "#!/bin/bash
set -e
/opt/maven/bin/mvn -V -T2C clean install -DskipTests -Ddependency-check.skip=true -Ddocker=false -P !mac-dmg-on-mac,!codesign-mac-dmg,!mac-dmg-on-unix,!installer,!concurrency-stress-tests,!micro-benchmarks,!build-dist-archives",
}

file { 'existdb_site_script':
  ensure  => file,
  path    => "${existdb_source_folder}/site.sh",
  replace => false,
  owner   => $existdb_source_folder_owner,
  group   => $existdb_source_folder_owner,
  mode    => '0770',
  require => [
    Vcsrepo['existdb_source'],
    File['/opt/maven'],
  ],
  content => "#!/bin/bash
set -e
/opt/maven/bin/mvn -V clean site -Ddependency-check.skip=true",
}

group { 'sys_existdb_group':
  ensure => present,
  name   => $sys_existdb_group,
  system => true,
}

user { 'sys_existdb_user':
  ensure     => present,
  name       => $sys_existdb_user,
  gid        => $sys_existdb_group,
  comment    => 'eXist-db Server Service Account',
  system     => true,
  managehome => false,
  home       => '/nonexistent',
  shell      => '/usr/sbin/nologin',
  require    => Group['sys_existdb_group'],
}

file { 'app_mount':
  ensure  => directory,
  path    => $app_mount,
  replace => false,
  owner   => 'root',
  group   => 'root',
  mode    => '0755',
}

file { 'sys_existdb_home':
  ensure  => directory,
  path    => $sys_existdb_home,
  replace => false,
  owner   => $sys_existdb_user,
  group   => $sys_existdb_group,
  mode    => '0770',
  require => [
    User['sys_existdb_user'],
    Group['sys_existdb_group'],
    File['app_mount'],
  ],
}

file { 'data_mount':
  ensure  => directory,
  path    => $data_mount,
  replace => false,
  owner   => 'root',
  group   => 'root',
  mode    => '0755',
}

file { 'sys_existdb_data':
  ensure  => directory,
  path    => $sys_existdb_data,
  replace => false,
  owner   => $sys_existdb_user,
  group   => $sys_existdb_group,
  mode    => '0770',
  require => [
    User['sys_existdb_user'],
    Group['sys_existdb_group'],
    File['data_mount'],
  ],
}

exec { 'compile-existdb':
  cwd         => $existdb_source_folder,
  command     => "${existdb_source_folder}/quick-build.sh",
  environment => [
    'JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-amd64',
  ],
  user        => $existdb_source_folder_owner,
  creates     => "${existdb_source_folder}/exist-distribution/target/exist-distribution-${existdb_version}-dir",
  timeout     => 600,
  require     => [
    Package['jdk17'],
    File['/opt/maven'],
    File['existdb_quick_build_script'],
  ],
}
-> exec { 'deploy-existdb':
  command => "/usr/bin/cp -r ${existdb_source_folder}/exist-distribution/target/exist-distribution-${existdb_version}-dir/* ${sys_existdb_home}/",
  creates => "${sys_existdb_home}/lib",
  require => File['sys_existdb_home'],
}
~> augeas { 'set-existdb-data-dir':
  incl    => "${sys_existdb_home}/etc/conf.xml",
  lens    => 'Xml.lns',
  changes => [
    "set exist/db-connection/#attribute/files \"${sys_existdb_data}\"",
    "set exist/db-connection/recovery/#attribute/journal-dir \"${sys_existdb_data}\"",
  ],
}
~> exec { 'set-existdb-owner':
  command => "/usr/bin/chown -R ${sys_existdb_user}:${sys_existdb_group} ${sys_existdb_home}",
  user    => 'root',
  require => [
    User['sys_existdb_user'],
    Group['sys_existdb_group'],
    File['sys_existdb_home'],
  ],
}
~> exec { 'set-existdb-db-admin-password':
  command => "${sys_existdb_home}/bin/client.sh -s -l --user admin --xpath \"sm:passwd('admin', '${existdb_db_admin_password}')\"",
  creates => "${sys_existdb_data}/collections.dbx",
  user    => $sys_existdb_user,
  require => [
    User['sys_existdb_user'],
    File['sys_existdb_home'],
    File['sys_existdb_data'],
  ],
}

file { '/etc/systemd/system/existdb.service':
  ensure  => file,
  replace => false,
  owner   => $sys_existdb_user,
  group   => $sys_existdb_group,
  require => [
    User['sys_existdb_user'],
    Group['sys_existdb_group'],
    File['sys_existdb_home'],
    File['sys_existdb_data'],
  ],
  content => "[Unit]
Description=eXist-db Server
Documentation=http://www.exist-db.org/exist/apps/doc/
After=syslog.target

[Service]
Type=simple
User=${sys_existdb_user}
Group=${sys_existdb_group}
ExecStart=${sys_existdb_home}/bin/startup.sh

[Install]
WantedBy=multi-user.target
",
}
~> exec { 'systemd-reload':
  command => 'systemctl daemon-reload',
  path    => '/usr/bin',
  user    => 'root',
}

service { 'existdb':
  ensure  => running,
  name    => 'existdb',
  enable  => true,

  require => [
    File['/etc/systemd/system/existdb.service'],
    Exec['systemd-reload'],
    Exec['set-existdb-db-admin-password'],
    Service['chronyd'],
  ],
}

ufw::allow { 'existdb':
  port    => '8080',
  require => Service['existdb'],
}
