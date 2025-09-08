###
# Puppet Script for Fonts on Ubuntu 24.04
###

package { 'fontconfig':
  ensure  => installed,
}

package { 'libfreetype6':
  ensure  => installed,
}

exec { 'accept-ms-fonts-eula':
  command  => 'echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections',
  user     => 'root',
  group    => 'root',
  provider => shell,
}

package { 'ttf-mscorefonts-installer':
  ensure  => installed,
  require => [
    Exec['accept-ms-fonts-eula'],
    Package['fontconfig'],
    Package['libfreetype6'],
  ],
}

package { 'fonts-ubuntu-classic':
  ensure  => installed,
  require => [
    Package['fontconfig'],
    Package['libfreetype6'],
  ],
}

package { 'fonts-dejavu':
  ensure  => installed,
  require => [
    Package['fontconfig'],
    Package['libfreetype6'],
  ],
}

package { 'fonts-courier-prime':
  ensure  => installed,
  require => [
    Package['fontconfig'],
    Package['libfreetype6'],
  ],
}

package { 'fonts-cmu':
  ensure  => installed,
  require => [
    Package['fontconfig'],
    Package['libfreetype6'],
  ],
}

package { 'fonts-clear-sans':
  ensure  => installed,
  require => [
    Package['fontconfig'],
    Package['libfreetype6'],
  ],
}

package { 'fonts-anonymous-pro':
  ensure  => installed,
  require => [
    Package['fontconfig'],
    Package['libfreetype6'],
  ],
}
