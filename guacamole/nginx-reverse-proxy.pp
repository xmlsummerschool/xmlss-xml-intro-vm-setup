###
# Puppet Script to reverse-proxy Guacamole Client with Nginx on Ubuntu 22.04
###

include ufw

package { 'nginx':
  ensure => installed,
}

$nginx_config = @(NGINX_CONF_EOF/L)
  user www-data;
  worker_processes auto;
  pid /run/nginx.pid;
  include /etc/nginx/modules-enabled/*.conf;

  events {
    worker_connections 768;
    # multi_accept on;
  }

  http {
    sendfile on;
    tcp_nopush on;
    types_hash_max_size 2048;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
    ssl_prefer_server_ciphers on;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    gzip on;

    # NOTE(AR) assist in WebSocket proxying - https://nginx.org/en/docs/http/websocket.html
    map $http_upgrade $connection_upgrade {
        default upgrade;
        ''      close;
    }

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
  }
  | NGINX_CONF_EOF

file { 'nginx-config':
  ensure  => file,
  path    => '/etc/nginx/nginx.conf',
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  content => $nginx_config,
  require => Package['nginx'],
}

file { 'nginx-proxy-config':
  ensure  => file,
  path    => '/etc/nginx/sites-available/plum.evolvedbinary.com.conf',
  owner   => 'root',
  group   => 'root',
  mode    => '0644',
  content => 'server {
        listen 80;
        server_name plum.evolvedbinary.com;
        charset utf-8;
        access_log /var/log/nginx/plum.evolvedbinary.com_access.log;

        proxy_set_header    Host                    $host;
        proxy_set_header    X-Real-IP               $remote_addr;
        proxy_set_header    X-Forwarded-For         $proxy_add_x_forwarded_for;
        proxy_set_header    nginx-request-uri       $request_uri;

        location / {
                proxy_pass http://localhost:8080/guacamole/;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection $connection_upgrade;
        }
}',
  require => Package['nginx'],
}

file { 'enable-nginx-proxy-config':
  ensure  => link,
  path    => '/etc/nginx/sites-enabled/plum.evolvedbinary.com.conf',
  target  => '/etc/nginx/sites-available/plum.evolvedbinary.com.conf',
  require => File['nginx-proxy-config'],
}

service { 'nginx':
  ensure  => running,
  enable  => true,
  require => [
    Package['nginx'],
    File['nginx-config'],
    File['enable-nginx-proxy-config'],
  ],
}

ufw::allow { 'nginx':
  port    => '80',
  require => Service['nginx'],
}
