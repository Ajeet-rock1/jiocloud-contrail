#
# Class: contrail::webui
#   Provide web based ui
#
# == Parameters
# 
#
#
class contrail::webui (
  $package_ensure     = 'present',
  $contrail_ip        = $::ipaddress,
  $webui_ip           = $::ipaddress,
  $config_ip          = $::ipaddress,
  $analytics_data_ttl = 48, ## Number of hours to keep the data
  $cassandra_ip_list  = [$::ipaddress],
  $redis_ip           = $::ipaddress,
  $cassandra_port     = 9160,
  $glance_address     = $::ipaddress,
  $nova_address       = $::ipaddress,
  $keystone_address   = $::ipaddress,
  $cinder_address     = $::ipaddress,
  $collector_ip       = $::ipaddress,
) {

  package {['contrail-web-core','contrail-web-controller']:
    ensure => $package_ensure,
  }

  file { '/etc/contrail/config.global.js':
    ensure  => present,
    content => template("${module_name}/config.global.js.erb"),
    require=> [ Package['contrail-web-controller'],
                Package['contrail-web-core'] ],
  }

  file { '/etc/init.d/contrail-webui-jobserver':
    ensure => link,
    target => '/lib/init/upstart-job',
    require=> [ Package['contrail-web-controller'],
                Package['contrail-web-core'] ],
  }

  service {'contrail-webui-jobserver':
    ensure    => running,
    require   => [ Package['contrail-web-controller'],
                Package['contrail-web-core'] ],
    subscribe => File['/etc/contrail/config.global.js'],
  }

  file { '/etc/init.d/contrail-webui-webserver':     
    ensure => link,                                
    target => '/lib/init/upstart-job',               
    require=> [ Package['contrail-web-controller'],
                Package['contrail-web-core'] ],      
  }                                                

  ##
  # contrail-webui initscripts are looking for /usr/bin/node (for node js). So
  # making a softlink.
  ##

  file {'/usr/bin/node':
    ensure  => link,
    target  => '/usr/bin/nodejs',
    require => [ Package['contrail-web-controller'],                          
                Package['contrail-web-core'] ],
    before  => [ Service['contrail-webui-jobserver'],
                 Service['contrail-webui-webserver'] ],
  }
                                                   
  service {'contrail-webui-webserver':               
    ensure    => running,                          
    require   => [ Package['contrail-web-controller'], 
                Package['contrail-web-core'] ],    
    subscribe => File['/etc/contrail/config.global.js'],
  }                                                


}
