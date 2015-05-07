### Utility Module for downloading and untaring a tarball archive pulled off nexus
#
# $extract_dir = directory name where to extract the archive (e.g. "/home/ec2-user/log-courier-1.3")
# $source = http or https URL from which the file can be downloaded (e.g. "https://github.com/driskell/log-courier/archive/v1.3.zip")
# $owner = linux user who will own the extracted directory
# $group = linux group who will own the extracted directory
# $archive_type = the type of archive we're downloading (e.g. "zip" or "tgz")
#

define archive($extract_dir, $source, $owner, $group, $archive_type) {

  # create the directory where we will extract the archive
  exec { "mkdir -p $extract_dir":
    command => "/bin/mkdir -p $extract_dir",
    creates => "$extract_dir"
  }

  # identify the downloaded file name (e.g. "v1.3.zip" in "https://github.com/driskell/log-courier/archive/v1.3.zip")
  $source_file_name = regsubst($source, '^.*\/(.*)', '\1')

  # identify the local folder name (e.g. "log-courier-1.3" in "/home/ec2-user/log-courier-1.3")
  $local_extract_folder_name = regsubst($extract_dir, '^.*\/(.*)', '\1')

  # download the archive
  exec { "download $source":
    command => "/usr/bin/wget -q $source -O /tmp/$source_file_name",
    creates => "/tmp/$source_file_name",
    require => Exec["mkdir -p $extract_dir"]
  }

  # untar the tarball
  if $archive_type == 'tgz' {
    exec { "untar $source":
      command => "/bin/tar zxf /tmp/$source_file_name --directory=$extract_dir",
      require => Exec["download $source"],
      notify => Exec["chown -R $owner.$group $extract_dir"]
    }
  }
  # ...or unzip
  elsif $archive_type == 'zip' {
    exec { "unzip $source":
      command => "/usr/bin/unzip -o /tmp/$source_file_name -d $extract_dir",
      require => Exec["download $source"],
      notify => Exec["chown -R $owner.$group $extract_dir"]
    }
  }
  # ...or complain that we don't know what to do
  else {
    fail("Either you did not specify an 'archive_type', or the archive type '$archive_type' is not supported by the 'archive' module.")
  }

  # Now that our archive is downloaded and extracted...

  # Change ownership of the extract_dir to the specified user/group
  exec { "chown -R $owner.$group $extract_dir":
    command => "/bin/chown -R $owner.$group $extract_dir",
  }
}
