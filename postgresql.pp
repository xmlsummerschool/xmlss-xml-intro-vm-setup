###
# Puppet Script for PostgreSQL on Ubuntu 22.04
###

include apt

apt::source { 'postgresql':
  location => 'https://apt.postgresql.org/pub/repos/apt',
  release  => 'jammy-pgdg',
  repos    => 'main',
  comment  => 'PostgreSQL',
  key      => {
    id     => 'ACCC4CF8',
    source => 'https://www.postgresql.org/media/keys/ACCC4CF8.asc',
  },
}

package { 'postgresql':
  ensure  => installed,
  require => Apt::Source['postgresql'],
} ~> exec { 'set-postgresql-password':
  command => "/usr/bin/psql -c \"ALTER USER postgres PASSWORD '${postgresql_db_postgres_password}';\"",
  user    => 'postgres',
  require => Service['postgresql'],
}

service { 'postgresql':
  ensure  => running,
  require => Package['postgresql'],
}

# Install PostgreSQL JDBC driver - /usr/share/java/postgresql-jdbc4.jar
## JDBC connection string - jdbc:postgresql://localhost:5432/<database>
package { 'libpostgresql-jdbc-java':
  ensure  => installed,
  require => Package['postgresql'],
}

# TODO(AR) - Add SQL files for data to the exercises folder
