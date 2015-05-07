### Utility Module for appending to the end of a file. Will not append if the line already exists.
#
# $path = the file path to which the $line will be appended
# $line = the statement that will be appended to the file at $path
#
# Sample Usage:
# file_append { 'Run keep-trying-to-start-logstash.sh at boot':
#     path => '/etc/rc.local',
#     line => 'bash /home/ec2-user/keep-trying-to-start-logstash.sh'
#   }

define file_append($path, $line) {

  # create the directory where we will extract the archive
  exec { "append $line to $path":
    command => "/bin/grep -q -F \"$line\" $path || /bin/echo \"$line\" >> $path",
  }

}
