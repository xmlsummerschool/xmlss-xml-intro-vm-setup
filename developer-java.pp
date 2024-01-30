###
# Puppet Script for a Java Developer Environment on Ubuntu 22.04
###

$maven_version = '3.9.6'

# Install Adoptium Temurin JDK 17 (oXygen XML Editor only support Oracle or Temurin JDKs)
exec { 'add-adoptium-gpg-key':
  command => 'wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null',
  path    => '/usr/bin',
  user    => 'root',
  creates => '/etc/apt/trusted.gpg.d/adoptium.gpg',
}

file { 'add-adoptium-dep-repo':
  ensure  => file,
  path    => '/etc/apt/sources.list.d/adoptium.list',
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  content => 'deb https://packages.adoptium.net/artifactory/deb jammy main',
  require => Exec['add-adoptium-gpg-key'],
}
~> exec { 'update-apt-for-adoptium':
  command => 'apt update',
  path    => '/usr/bin',
  user    => 'root',
  unless  => 'dpkg -s temurin-17-jdk',
}

package { 'jdk17':
  ensure  => installed,
  name    => 'temurin-17-jdk',
  require => [
    Exec['update-apt-for-adoptium'],
  ],
}

file_line { 'JAVA_HOME':
  ensure  => present,
  path    => '/etc/environment',
  line    => 'JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-amd64',
  match   => '^JAVA_HOME\=',
  require => Package['jdk17'],
}

# Install JavaFX 17
exec { 'download-openjfx17':
  command => 'wget https://download2.gluonhq.com/openjfx/17.0.10/openjfx-17.0.10_linux-x64_bin-jmods.zip -O /tmp/openjdk-jmods.zip',
  path    => '/usr/bin',
  user    => 'root',
  creates => '/usr/lib/jvm/javafx-jmods-17.0.10',
  require => Package['wget'],
}
~> exec { 'extract-openjfx17':
  command => 'unzip /tmp/openjdk-jmods.zip -d /usr/lib/jvm',
  path    => '/usr/bin',
  user    => 'root',
  creates => '/usr/lib/jvm/javafx-jmods-17.0.10',
  require => Package['unzip'],
}
~> file_line { '_JAVA_OPTIONS':
  ensure => present,
  path   => '/etc/environment',
  line   => '_JAVA_OPTIONS="--module-path=/usr/lib/jvm/javafx-jmods-17.0.10 --add-modules=ALL-MODULE-PATH"',
  match  => '^_JAVA_OPTIONS\=',
}

exec { 'install-maven':
  command => "curl -L https://archive.apache.org/dist/maven/maven-3/${maven_version}/binaries/apache-maven-${maven_version}-bin.tar.gz | tar zxv -C /opt",
  path    => '/usr/bin',
  user    => 'root',
  creates => "/opt/apache-maven-${maven_version}",
  require => Package['curl'],
}

file { '/opt/maven':
  ensure  => link,
  target  => "/opt/apache-maven-${maven_version}",
  replace => false,
  owner   => 'root',
  group   => 'root',
  require => Exec['install-maven'],
}

file_line { 'MAVEN_HOME':
  ensure  => present,
  path    => '/etc/environment',
  line    => 'MAVEN_HOME=/opt/maven',
  match   => '^MAVEN_HOME\=',
  require => File['/opt/maven'],
}

file_line { 'PATH':
  ensure  => present,
  path    => '/etc/environment',
  line    => 'PATH=/opt/maven/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin',
  match   => '^PATH\=',
  require => File['/opt/maven'],
}
