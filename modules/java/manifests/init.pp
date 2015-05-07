# java module based on java salt state

class java {

  $jdk_ver_dir = "jdk1.8.0_20"
  $java_url_path = "http://nexus.chotel.com/nexus/service/local/repositories/thirdparty/content/com/oracle/java/server-jre/8u20/"
  $java_file = "server-jre-8u20-linux-x64.tgz"

  exec { "java_install archive":
    command => "/bin/mkdir /usr/java; /usr/bin/wget $java_url_path/$java_file -O /usr/java/$java_file; /bin/tar -C /usr/java -xzvf /usr/java/$java_file; /bin/chown -R root:root /usr/java",
    unless => "/usr/bin/test -e /usr/java/$java_file"
  }

  file { "/usr/java/$jdk_ver_dir":
    ensure => "directory",
    owner  => "root",
    group  => "root",
    mode   => "0755",
    require => Exec["java_install archive"]
  }

  exec { "symlink_java latest":
    command => "/bin/rm -rf /usr/java/latest; /bin/ln -s /usr/java/$jdk_ver_dir /usr/java/latest",
    require => Exec["java_install archive"]
  }

  exec { "symlink_java default":
    command => "/bin/rm -rf /usr/java/default; /bin/ln -s /usr/java/latest /usr/java/default",
    require => Exec["symlink_java latest"]
  }

  exec { "symlink_java bin":
    command => "/bin/rm -rf /usr/bin/java; /bin/ln -s /usr/java/latest/bin/java /usr/bin/java",
    require => Exec["symlink_java default"]
  }

 file { "/etc/profile.d/java.sh":
    replace => true,
    source => "puppet:///modules/java/java.sh",
    mode => "0644",
    owner => "root",
    group => "root",
    require => Exec["symlink_java bin"]
  }

}
