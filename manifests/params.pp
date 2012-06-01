class oracleprereq::params {

  $glibc = $::architecture ? {
    i386      => $::operatingsystemrelease ? {
                  /^5.*$/ => ['glibc-devel.i386','glibc-headers'],
                  /^6.*$/ => ['glibc-devel.i686','glibc-headers'],
    },
    x86_64    => $::operatingsystemrelease ? {
                  /^5.*$/ => ['glibc-devel.i386','glibc-devel.x86_64','glibc-headers'],
                  /^6.*$/ => ['glibc-devel.i686','glibc-devel.x86_64','glibc-headers'],
    },
  }

  $libpackages = ['libaio',
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
                  'compat-libstdc++-33',
                  'compat-db']
  $systemtools = ['ksh',
                  'bind-utils',
                  'smartmontools',
                  'ftp',
                  'libgomp',
                  'unzip',
                  'sysstat',
                  'device-mapper-multipath']
}
