###
# Puppet Script for IBM Data Studio on Ubuntu 22.04
###

$ibm_data_studio_setup_path = '/tmp/ibm-data-studio-setup'
$ibm_installation_manager_setup_name = 'agent.installer.linux.gtk.x86_64_1.9.1006.20210614_1906'
$ibm_installation_manager_setup_path = "${ibm_data_studio_setup_path}/${ibm_installation_manager_setup_name}"
$ibm_installation_manager_eclipse_path = '/opt/ibm/installation-manager/eclipse'
$ibm_data_studio_im_offering_name = 'com.ibm.dsida.im-offering-build-4.1.4-20211124.160709-33-im-offering'
$ibm_data_studio_im_offering_path = "${ibm_data_studio_setup_path}/${ibm_data_studio_im_offering_name}"
$ibm_shared_path = '/opt/ibm/sdp-shared'
$ibm_data_studio_path = '/opt/ibm/data-studio'
$ibm_data_studio_response_file_path = '/tmp/datastudio.rsp'

file { 'ibm-data-studio-setup-path':
  ensure  => directory,
  path    => $ibm_data_studio_setup_path,
  replace => false,
  owner   => 'root',
  group   => 'root',
}

exec { 'download-ibm-data-studio':
  command => "curl https://iwm.dhe.ibm.com/sdfdl/v2/regs2/smkane/DS22_IDETAB/Xa.2/Xb.ZaTctOS40LvTqXh53uXoCJnQ7X07SzdrjzL8w_BS2lo/Xc.ibm_ds4140_lin.tar.gz/Xd./Xf.lPr.D1vk/Xg.12700405/Xi.swg-idside/XY.regsrvs/XZ.2GyzNg7z8l1NQBRoZAf0IyBXbZd_3DCX/ibm_ds4140_lin.tar.gz | tar zxv -C ${ibm_data_studio_setup_path}",
  path    => '/usr/bin',
  user    => 'root',
  group   => 'root',
  creates => "${ibm_data_studio_setup_path}/documentation/",
  unless  => "file ${ibm_installation_manager_eclipse_path}",
  require => [
    Package['curl'],
    File['ibm-data-studio-setup-path']
  ],
}

file { 'ibm-installation-manager-setup-path':
  ensure  => directory,
  path    => $ibm_installation_manager_setup_path,
  replace => false,
  owner   => 'root',
  group   => 'root',
  require => File['ibm-data-studio-setup-path'],
}

exec { 'unzip-ibm-installation-manager-setup':
  command => "unzip ${ibm_installation_manager_setup_path}.zip -d ${ibm_installation_manager_setup_path}",
  path    => '/usr/bin',
  user    => 'root',
  group   => 'root',
  unless  => "file ${ibm_installation_manager_eclipse_path}/IBMIM",
  require => [
    Exec['download-ibm-data-studio'],
    File['ibm-installation-manager-setup-path']
  ],
}

$ibm_installation_manager_install_xml = @("IBM_IM_INSTALL_XML_EOF":xml/L)
  <?xml version="1.0" encoding="UTF-8"?>
  <agent-input clean='true' temporary='true'>
    <profile kind='self' installLocation='${ibm_installation_manager_eclipse_path}' id='IBM Installation Manager'>
      <data key='eclipseLocation' value='${ibm_installation_manager_eclipse_path}'/>
    </profile>
    <server>
      <repository location='.'/>
    </server>
    <install>
      <offering features='agent_core,agent_jre' id='com.ibm.cic.agent' version='1.9.1006.20210614_1906'/>
    </install>
  </agent-input>
  | IBM_IM_INSTALL_XML_EOF

file { 'ibm-installation-manager-install-xml':
  ensure  => file,
  path    => "${ibm_installation_manager_setup_path}/install.xml",
  owner   => 'root',
  group   => 'root',
  content => $ibm_installation_manager_install_xml,
  require => [
    File['ibm-data-studio-setup-path'],
    Exec['unzip-ibm-installation-manager-setup'],
  ],
}

exec { 'install-installation-manager':
  command  => "${ibm_installation_manager_setup_path}/installc -log ${ibm_installation_manager_setup_path}/install.log.xml -acceptLicense",
  user     => 'root',
  group    => 'root',
  provider => shell,
  creates  => "${ibm_installation_manager_eclipse_path}/IBMIM",
  require  => [
    Exec['unzip-ibm-installation-manager-setup'],
    File['ibm-installation-manager-install-xml'],
  ],
}

$ibm_data_studio_response_file = @("IBM_DATA_STUDIO_RESPONSE_FILE_EOF":xml/L$)
  <?xml version='1.0' encoding='UTF-8'?>
  <agent-input>
    <variables>
      <variable name='sharedLocation' value='${ibm_shared_path}'/>
    </variables>
    <server>
      <repository location='${ibm_data_studio_im_offering_path}.zip'/>
    </server>
    <profile id='IBM Data Studio' installLocation='${ibm_data_studio_path}'>
      <data key='cic.selector.arch' value='x86_64'/>
    </profile>
    <install>
      <!-- IBM Data Studio client 4.1.4.0 -->
      <offering profile='IBM Data Studio' id='com.ibm.dsida.v414' version='4.1.4.20211124_1122' features='com.ibm.ids.core,com.ibm.ids.jdk,com.ibm.app.dev,com.ibm.db.admin,tune'/>
    </install>
    <preference name='com.ibm.cic.common.core.preferences.eclipseCache' value='\${sharedLocation}'/>
  </agent-input>
  | IBM_DATA_STUDIO_RESPONSE_FILE_EOF

file { 'ibm-data-studio-response-file':
  ensure  => file,
  path    => $ibm_data_studio_response_file_path,
  owner   => 'root',
  group   => 'root',
  mode    => '0660',
  content => $ibm_data_studio_response_file,
}

exec { 'install-ibm-data-studio':
  command  => "${ibm_installation_manager_eclipse_path}/tools/imcl input ${$ibm_data_studio_response_file_path} -log ${ibm_data_studio_setup_path}/data-studio-install.log.xml -acceptLicense",
  user     => 'root',
  group    => 'root',
  provider => shell,
  creates  => "${ibm_data_studio_path}/eclipse",
  require  => [
    Exec['download-ibm-data-studio'],
    Exec['install-installation-manager'],
    File['ibm-data-studio-response-file'],
  ],
}

# Add Desktop shortcut
file { 'ibm-data-studio-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/ibm-data-studio.desktop",
  source  => '/usr/share/applications/IBMIM0DataStudio012124.1.4Client1234.desktop',
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    Exec['install-ibm-data-studio'],
  ],
}

exec { 'gvfs-trust-ibm-data-studio-desktop-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/ibm-data-studio.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/ibm-data-studio.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['ibm-data-studio-desktop-shortcut'],
}
