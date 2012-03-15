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
  require 'sudo'

  group { 'oinstall':
    ensure => present,
    name   => 'oinstall',
    gid    => '1001'
  }

  group { 'dba':
    ensure => present,
    name   => 'dba',
    gid    => '1002'
  }

  user { 'oracle':
    ensure      => present,
    name        => 'oracle',
    uid         => '1001',
    gid         => 'oinstall',
    groups      => 'dba',
    comment     => 'Oracle Admin user',
    home        => '/home/oracle',
    managehome  => true,
    password    => '$1$gBOOf7ks$X8IXfSUXNLn8KR8LB1qMG1',
    shell       => '/bin/bash',
    subscribe   => [Group['oinstall'], Group['dba']]
  }
  $libpackages = ['compat-libstdc++-33', 'glibc-devel.i386',
                  'glibc-devel.x86_64', 'glibc-headers', 'libaio',
                  'libaio-devel', 'numactl-devel', 'elfutils-libelf-devel',
                  'unixODBC', 'unixODBC-devel', 'xorg-x11-xauth']
  $buildpackages = [ 'make' , 'cpp', 'libstdc++-devel', 'gcc', 'gcc-c++',
                  'compat-db']
  $systemtools = ['ksh', 'bind-utils', 'smartmontools', 'ftp', 'libgomp',
                  'unzip' ,'sysstat']
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
#  augeas { 'sudoers':
#    context => '/files/etc/sudoers',
#    changes => [
#      'set spec[01]/user oracle',
#      'set spec[01]/host_group/host ALL',
#      'set spec[01]/host_group/command "/bin/su"',
#    ]
#  }

  sudo::alias { 'ORADM':
    ensure      => present,
    sudo_alias  => 'User_Alias',
    items       => ['oracle']
  }

  sudo::alias {'ADM':
    ensure      => present,
    sudo_alias  => 'Cmnd_Alias',
    items       => ['/bin/su']
  }

  sudo::spec { 'oracle':
    users     => 'oracle',
    hosts     => 'ALL',
    commands  => 'ADM',
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
