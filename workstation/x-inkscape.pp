###
# Puppet Script for Inkscape on Ubuntu 24.04
###

package { 'inkscape':
  ensure  => installed,
  require => Package['desktop'],
}

xdesktop::shortcut { 'Inkscape':
  shortcut_source => '/usr/share/applications/org.inkscape.Inkscape.desktop',
  user            => $default_user,
  position        => {
    provider => 'lxqt',
    x        => 139,
    y        => 516,
  },
  require         => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    File['desktop-items-0'],
    Package['inkscape'],
  ],
}
