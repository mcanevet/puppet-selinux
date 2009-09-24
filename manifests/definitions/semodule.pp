define selinux::module ($workdir="/tmp/", $dest="/usr/share/selinux/targeted/", $content=undef, $source=undef) {

  file { "$workdir":
    ensure => directory,
  }

  if $content {
    file { "${workdir}/${name}.te":
      ensure => present,
      content => $content,
      require => File[$workdir],
      notify => Exec["build selinux policy module ${name}"],
    }
  }
  if $source {
    file { "${workdir}/${name}.te":
      ensure => present,
      source => $source,
      require => File[$workdir],
      notify => Exec["build selinux policy module ${name}"],
    }
  }

  exec { "build selinux policy module ${name}":
    cwd => $workdir,
    command => "checkmodule -M -m ${name}.te -o ${name}.mod",
    refreshonly => true,
    require => [File["${workdir}/${name}.te"], Package["checkpolicy"]],
    notify => Exec["build selinux policy package ${name}"],
  }

  exec { "build selinux policy package ${name}":
    cwd => $workdir,
    command => "semodule_package -o ${dest}/${name}.pp -m ${name}.mod",
    refreshonly => true,
    require => [Exec["build selinux policy module ${name}"], Package["policycoreutils"]],
  }
}