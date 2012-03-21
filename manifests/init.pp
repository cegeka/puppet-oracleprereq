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

  $libpackages = ['compat-libstdc++-33',
                  'glibc-devel.i386',
                  'glibc-devel.x86_64',
                  'glibc-headers',
                  'libaio',
                  'libaio-devel',
                  'numactl-devel',
                  'elfutils-libelf-devel',
                  'unixODBC',
                  'unixODBC-devel',
                  'xorg-x11-xauth']
  $buildpackages = ['make',
                  'cpp',
                  'libstdc++-devel',
                  'gcc',
                  'gcc-c++',
                  'compat-db']
  $systemtools = ['ksh',
                  'bind-utils',
                  'smartmontools',
                  'ftp',
                  'libgomp',
                  'unzip',
                  'sysstat']
  package { [$libpackages,$buildpackages,$systemtools]:
    ensure => present,
  }
  package { ["oracleasm-$::kernelrelease",'oracleasmlib','oracleasm-support']:
    ensure => present,
  }

  augeas { 'sysctl.conf':
    context => '/files/etc/sysctl.conf',
    changes => [
      'set fs.aio-max-nr 1048576',
      'set fs.file-max 6815744',
      'set kernel.shmall 2097152',
      'set kernel.shmmax 4294967295',
      'set kernel.shmmni 4096',
      'set kernel.sem "250 32000 100 128"',
      'set net.ipv4.ip_local_port_range "9000 65500"',
      'set net.core.rmem_default 262144',
      'set net.core.rmem_max 4194304',
      'set net.core.wmem_default 262144',
      'set net.core.wmem_max 1048586'
    ]
  }

  exec { 'sysctl -p':
    path        => ['/usr/bin', '/usr/sbin', '/sbin'],
    subscribe   => Augeas['sysctl.conf'],
    refreshonly => true
  }

  file { '/etc/multipath.conf':
    ensure  => present,
    content => template('oracleprereq/multipath.erb')
  }

  service { 'multipathd':
    ensure    => running,
    hasstatus => true,
  }
}
