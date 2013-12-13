# Class: oracleprereq
#
# This module manages oracleprereq
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class oracleprereq {

  include oracleprereq::params

  package { [$oracleprereq::params::libpackages,$oracleprereq::params::glibc,$oracleprereq::params::buildpackages,$oracleprereq::params::systemtools]:
    ensure => present,
  }
  # There is no oracleasm package for rhel6
  if $::operatingsystemrelease =~ /^5.*$/ {
    if $::architecture == 'x86_64' {
      package { ["oracleasm-${::kernelrelease}",'oracleasmlib','oracleasm-support']:
        ensure => present,
      }
    }

    augeas { 'oracleasm':
      lens      => 'Oracleasm.lns',
      incl      => '/etc/sysconfig/oracleasm',
      changes   => 'set ORACLEASM_SCANEXCLUDE \'"sd"\'',
      load_path => "${settings::vardir}/lib/augeas/lenses",
      require   => Package['oracleasmlib'],
    }

    file { '/etc/multipath.conf':
      ensure  => present,
      content => template('oracleprereq/multipath.5.erb'),
    }
  }
  else {
    file { '/etc/multipath.conf':
      ensure  => present,
      content => template('oracleprereq/multipath.6.erb'),
    }
  }

  $memsize_bytes = to_bytes($::memorysize)
  $shmall = floor($memsize_bytes / $::pagesize)

  augeas { 'sysctl.conf':
    context => '/files/etc/sysctl.conf',
    changes => [
      'set fs.aio-max-nr 1048576',
      'set fs.file-max 6815744',
      "set kernel.shmall ${shmall}",
      'set kernel.shmmax 4294967295',
      'set kernel.shmmni 4096',
      'set kernel.sem "250 32000 100 128"',
      'set net.ipv4.ip_local_port_range "9000 65500"',
      'set net.core.rmem_default 262144',
      'set net.core.rmem_max 4194304',
      'set net.core.wmem_default 262144',
      'set net.core.wmem_max 1048586',
      'set vm.swappiness 100'
    ]
  }

  exec { 'sysctl -e -p':
    path        => ['/usr/bin', '/usr/sbin', '/sbin'],
    subscribe   => Augeas['sysctl.conf'],
    refreshonly => true,
  }

  service { 'multipathd':
    ensure    => running,
    hasstatus => true,
    require   => Package['device-mapper-multipath'],
  }
}
