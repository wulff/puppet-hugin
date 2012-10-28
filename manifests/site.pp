# basic site manifest

# define global paths and file ownership
Exec { path => '/usr/sbin/:/sbin:/usr/bin:/bin' }
File { owner => 'root', group => 'root' }

# create a stage to make sure apt-get update is run before all other tasks
stage { 'requirements': before => Stage['main'] }
stage { 'bootstrap': before => Stage['requirements'] }

class hugin::bootstrap {
  # we need an updated list of sources before we can apply the configuration
	exec { 'hugin_apt_update':
		command => '/usr/bin/apt-get update',
	}
}

class hugin::requirements {
  # install git-core and add some useful aliases
  class { 'git': }

  apt::source { 'mariadb':
    location    => 'http://ftp.osuosl.org/pub/mariadb/repo/5.5/ubuntu',
    release     => 'precise',
    repos       => 'main',
    key         => '1BB943DB',
    include_src => true,
  }
}

class hugin::install {

  # install apache, mariadb, and php

  class { 'apache': }
  apache::mod { 'php5': }
  apache::mod { 'rewrite': }

  file { '/var/www/index.html':
    ensure  => absent,
    require => Package['httpd'],
  }

  # install mariadb

  class { 'mysql::server':
    # use the mysql module to install the mariadb packages
    package_name     => 'mariadb-server',
#   config_hash      => { 'root_password' => 'root' },
    # necessary because /sbin/status doesn't know about mysql on ubuntu
    service_provider => 'debian',
  }

  # install php

  class { 'php': }

  php::module { 'curl': }
  php::module { 'gd': }
  php::module { 'mysqlnd':
    restart => Service['apache2'],
  }

  # install drush

  php::pear::package { 'Console_Table': }

# this is super-slow, don't use when testing puppet!
#  php::pear::package { 'drush':
#    repository => 'pear.drush.org',
#    version    => latest,
#  }

  file { ['/usr/share/drush', '/usr/share/drush/commands']:
    ensure => directory,
  }

  # install solr

  class { 'solr': }

  # configure site: psyke.org

  file { '/var/www/psyke.org':
    ensure  => directory,
    require => Package['httpd'],
  }
  apache::vhost { 'psyke.org':
    priority      => '10',
    serveraliases => ['psyke.org.33.33.33.10.xip.io'],
    port          => '80',
    docroot       => '/var/www/psyke.org',
    ssl           => false,
    serveradmin   => 'wulff@ratatosk.net',
    override      => 'All',
  }
  mysql::db { 'd7_psyke_org':
    user     => 'drupal',
    password => 'drupal',
  }

# ratatosk.net.33.33.33.10.xip.io

#  class { 'solr':
#    cores => ['psyke.org', 'ratatosk.net'],
#  }
}

class hugin::go {
  class { 'hugin::bootstrap':
    stage => 'bootstrap',
  }
  class { 'apt':
    stage => 'requirements',
  }
  class { 'hugin::requirements':
    stage => 'requirements',
  }
  class { 'hugin::install': }
}

include hugin::go