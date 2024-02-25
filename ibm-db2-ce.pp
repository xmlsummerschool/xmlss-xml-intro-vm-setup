###
# Puppet Script for IBM Db2 Community Edition on Ubuntu 22.04
###
$ibm_db2_major_version = '11'
$ibm_db2_minor_version = '5'
$ibm_db2_patch_version = '9'
$ibm_db2_version = "${ibm_db2_major_version}.${ibm_db2_minor_version}.${ibm_db2_patch_version}"
$ibm_db2_path = "/opt/ibm/db2/V${ibm_db2_major_version}.${ibm_db2_minor_version}"
$ibm_db2_setup_response_file = '/tmp/db2server.rsp'

exec { 'download-ibm-db2':
  command => "curl https://s3.us-south.cloud-object-storage.appdomain.cloud/epwt-program-files/13463?response-content-disposition=attachment%3B%20filename%3D%22v${$ibm_db2_version}_linuxx64_server_dec.tar.gz%22&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20240221T162510Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=37243a2f428a4803b9012abc82733744%2F20240221%2Fus%2Fs3%2Faws4_request&X-Amz-Signature=212330505b70680acc618779ecf207e94a0474b3f2c8600d3c2f5441a69495a4 | tar zxv -C /tmp",
  path    => '/usr/bin',
  user    => 'root',
  group   => 'root',
  creates => '/tmp/server_dec',
  unless  => "file ${ibm_db2_path}",
  require => [
    Package['file'],
    Package['curl'],
  ]
}

# Error: /Stage[main]/Main/Exec[download-ibm-db2]: Could not evaluate: Could not find command '/usr/bin/file'

$ibm_db2_response_file = @("IBM_DB2_RESPONSE_FILE_EOF":xml/L)
  *-----------------------------------------------------
  * Generated response file used by the DB2 Setup wizard
  * generation time: 21/02/24 17:17
  *-----------------------------------------------------
  *  Product Installation 
  LIC_AGREEMENT       = ACCEPT
  PROD       = DB2_SERVER_EDITION
  FILE       = ${ibm_db2_path}
  INSTALL_TYPE       = CUSTOM
  COMP       = SQL_PROCEDURES
  COMP       = INSTANCE_SETUP_SUPPORT
  COMP       = CONNECT_SUPPORT
  COMP       = JDBC_DATA_SOURCE_SUPPORT
  COMP       = IINR_STRUCTURED_FILES_WRAPPER
  COMP       = BASE_DB2_ENGINE
  COMP       = REPL_CLIENT
  COMP       = JDK
  COMP       = DB2_SAMPLE_DATABASE
  COMP       = JAVA_SUPPORT
  COMP       = FIRST_STEPS
  COMP       = BASE_CLIENT
  COMP       = COMMUNICATION_SUPPORT_TCPIP
  *-----------------------------------------------
  *  Das properties 
  *-----------------------------------------------
  DAS_CONTACT_LIST       = LOCAL
  * ----------------------------------------------
  *  Instance properties           
  * ----------------------------------------------
  INSTANCE       = inst1
  inst1.TYPE       = ese
  *  Instance-owning user
  inst1.NAME       = db2inst1
  inst1.GROUP_NAME       = db2iadm1
  inst1.HOME_DIRECTORY       = /home/db2inst1
  * inst1.PASSWORD       = db2
  inst1.PASSWORD       = 226534209152763014799290572302274234081808476017653273626011526323883543648688611541615544402433261182446105632468292813448161138854511662724090955095240618444744438321463835344820367312294965454627156067364326564725456373740495297133059292841403393505032143622438248108022216803180062144346364436664567244583237511042002329329256059033142554312655642463866495649496664658724728394098598242772484632246433374973039603121025072507544335342446358059558283445200652922255614737043556222760024615016099281747997200079196753603656163445024639230804279266986492264572251052876965562462554726329122310452293732218576912756325753348966466142953033280533541939112404234762419176332536710194621898294955410685263549124826571262721613332772739456201028843967094556633044410773968
  ENCRYPTED       = inst1.PASSWORD
  inst1.AUTOSTART       = YES
  inst1.SVCENAME       = db2c_db2inst1
  inst1.PORT_NUMBER       = 25000
  inst1.FCM_PORT_NUMBER       = 20000
  inst1.MAX_LOGICAL_NODES       = 6
  inst1.CONFIGURE_TEXT_SEARCH       = NO
  *  Fenced user
  inst1.FENCED_USERNAME       = db2fenc1
  inst1.FENCED_GROUP_NAME       = db2fadm1
  inst1.FENCED_HOME_DIRECTORY       = /home/db2fenc1
  * inst1.FENCED_PASSWORD       = db2
  inst1.FENCED_PASSWORD       = 752376946858701450771575234682649207686777745440115732048445868417142154354316535570947917112779091427864745723742512223243234454325247644432303599154054629043216324681538336082422736314044265147534600364222312224443870117966868085441566702549943695294336241269518946452375630136621515373912679844602265245304765255233595007345262436824030026742263256001667926330845340470856254652464322189126642463025725562102225161159151922721284773655507139704188047653175937547312543196359054335034168110452311256950121133429673024323120173625932849185216315364224274263518232666183455123485553021928162488277324316795325836125861240434740345165899936525342324602194694425528979665495620302532575953331344515091052293236766854797264872156484452620653984634122626286629325012381590
  ENCRYPTED       = inst1.FENCED_PASSWORD
  *-----------------------------------------------
  *  Installed Languages 
  *-----------------------------------------------
  LANG       = EN
  | IBM_DB2_RESPONSE_FILE_EOF

file { 'ibm-db2-setup-response-file':
  ensure  => file,
  path    => $ibm_db2_setup_response_file,
  owner   => 'root',
  group   => 'root',
  mode    => '0660',
  content => $ibm_db2_response_file,
}

exec { 'install-ibm-db2':
  command  => "/tmp/server_dec/db2setup -r ${ibm_db2_setup_response_file}",
  user     => 'root',
  group    => 'root',
  provider => shell,
  creates  => "${ibm_db2_path}/bin/db2",
  require  => [
    Exec['download-ibm-db2'],
    File['ibm-db2-setup-response-file'],
  ],
}

service { 'db2fmcd':
  ensure  => running,
  require => Exec['install-ibm-db2'],
}

exec { 'install-sample-db':
  command  => '/home/db2inst1/sqlllib/bin/db2sampl',
  user     => 'db2inst1',
  creates  => '/home/db2inst1/db2inst1/NODE0000/SAMPLE',
  provider => shell,
  require  => Service['db2fmcd'],
}

# DB2 JDBC driver - /opt/ibm/db2/V11.5/java/db2jcc4.jar
## JDBC connection string - jdbc:db2://localhost:25000/<database>

# Add DB2 Client Desktop link
file { 'db2-client-desktop-shortcut':
  ensure  => file,
  path    => "/home/${default_user}/Desktop/db2-client.desktop",
  owner   => $default_user,
  group   => $default_user,
  mode    => '0644',
  content => "[Desktop Entry]
Version=1.0
Type=Application
Name=DB2 Client
Exec=su - db2inst1 -c db2
Icon=${ibm_db2_path}/desktop/icons/db2.xpm
Terminal=true
StartupNotify=false
GenericName=DB2 Client
",
  require => [
    Package['desktop'],
    File['default_user_desktop_folder'],
    Exec['install-ibm-db2'],
  ],
}

exec { 'gvfs-trust-db2-client-desktop-shortcut':
  command     => "/usr/bin/gio set /home/${default_user}/Desktop/db2-client.desktop metadata::trusted true",
  unless      => "/usr/bin/gio info --attributes=metadata::trusted /home/${default_user}/Desktop/db2-client.desktop | /usr/bin/grep trusted",
  user        => $default_user,
  environment => [
    'DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus',
  ],
  require     => File['db2-client-desktop-shortcut'],
}

# TODO(AR) - Add SQL files for data to the exercises folder
