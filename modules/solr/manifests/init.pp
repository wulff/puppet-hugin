# == Class: solr
#
# This class installs Tomcat and a Solr instance with multicore support.
#
# === Examples
#
#   class { 'solr': }
#
class solr {
  package { ['tomcat6', 'tomcat6-admin']: }

  service { 'tomcat6':
    ensure  => running,
    require => Package['tomcat6'],
  }

  file { '/etc/tomcat6/tomcat-users.xml':
    source  => 'puppet:///modules/solr/tomcat-users.xml',
    owner   => 'root',
    group   => 'tomcat6',
    mode    => 0640,
    require => Package['tomcat6'],
    notify  => Service['tomcat6'],
  }

  file { '/etc/tomcat6/Catalina/localhost/solr.xml':
    source  => 'puppet:///modules/solr/solr-catalina.xml',
    owner   => 'tomcat6',
    group   => 'tomcat6',
    require => Package['tomcat6'],
    notify  => Service['tomcat6'],
  }

  file { ['/opt/solr', '/opt/solr/example', '/opt/solr/example/solr']:
    ensure => directory,
    owner  => 'tomcat6',
    group  => 'tomcat6',
  }

  exec { 'hugin-solr-download':
    cwd     => '/root',
    command => 'wget http://mirrors.rackhosting.com/apache/lucene/solr/3.6.1/apache-solr-3.6.1.tgz && tar xzf apache-solr-3.6.1.tgz',
    creates => '/root/apache-solr-3.6.1',
  }

  file { '/opt/solr/example/solr/solr.war':
    source  => '/root/apache-solr-3.6.1/dist/apache-solr-3.6.1.war',
    owner   => 'tomcat6',
    group   => 'tomcat6',
    require => [File['/opt/solr/example/solr'], Exec['hugin-solr-download']],
    notify  => Service['tomcat6'],
  }

  file { '/opt/solr/example/solr/solr.xml':
    source  => 'puppet:///modules/solr/solr.xml',
    owner   => 'tomcat6',
    group   => 'tomcat6',
    require => File['/opt/solr/example/solr'],
    notify  => Service['tomcat6'],
  }

  file { ['/opt/solr/example/solr/psyke.org', '/opt/solr/example/solr/psyke.org/conf']:
    ensure  => directory,
    owner   => 'tomcat6',
    group   => 'tomcat6',
    require => File['/opt/solr/example/solr']
  }
  exec { 'hugin-solr-psyke-conf':
    command => 'cp -r /root/apache-solr-3.6.1/example/solr/conf/* /opt/solr/example/solr/psyke.org/conf',
    require => [Exec['hugin-solr-download'], File['/opt/solr/example/solr/psyke.org/conf']],
  }
  file { '/opt/solr/example/solr/psyke.org/conf/schema.xml':
    source  => 'puppet:///modules/solr/schema.xml',
    require => File['/opt/solr/example/solr/psyke.org/conf'],
    notify  => Service['tomcat6'],
  }
  file { '/opt/solr/example/solr/psyke.org/conf/solrconfig.xml':
    source  => 'puppet:///modules/solr/solrconfig.xml',
    require => File['/opt/solr/example/solr/psyke.org/conf'],
    notify  => Service['tomcat6'],
  }

  file { ['/opt/solr/example/solr/ratatosk.net', '/opt/solr/example/solr/ratatosk.net/conf']:
    ensure  => directory,
    owner   => 'tomcat6',
    group   => 'tomcat6',
    require => File['/opt/solr/example/solr']
  }
  exec { 'hugin-solr-ratatosk-conf':
    command => 'cp -r /root/apache-solr-3.6.1/example/solr/conf/* /opt/solr/example/solr/ratatosk.net/conf',
    require => [Exec['hugin-solr-download'], File['/opt/solr/example/solr/ratatosk.net/conf']],
  }
  file { '/opt/solr/example/solr/ratatosk.net/conf/schema.xml':
    source  => 'puppet:///modules/solr/schema.xml',
    require => File['/opt/solr/example/solr/ratatosk.net/conf'],
    notify  => Service['tomcat6'],
  }
  file { '/opt/solr/example/solr/ratatosk.net/conf/solrconfig.xml':
    source  => 'puppet:///modules/solr/solrconfig.xml',
    require => File['/opt/solr/example/solr/ratatosk.net/conf'],
    notify  => Service['tomcat6'],
  }
}