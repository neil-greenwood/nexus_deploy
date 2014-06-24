# Class: nexus_deploy
#
# This module downloads Maven Artifacts from Nexus to support deployment
#
# Parameters:
# [*url*] : The Nexus base url (mandatory)
# [*username*] : The username used to connect to nexus
# [*password*] : The password used to connect to nexus
#
# Actions:
# Checks and intialized the Nexus support.
#
# Sample Usage:
#  class nexus_deploy {
#   url => http://edge.spree.de/nexus,
#   username => user,
#   password => password
# }
#
class nexus_deploy (
    $url,

    $username = undef,
    $password = undef,
) {

    if $username and $password {
        $authentication = true
    } else {
        $authentication = false
    }

# Install script
    file {
      '/opt/nexus-script/download-artifact-from-nexus.sh':
        ensure => file,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
        source => 'puppet:///modules/nexus_deploy/download-artifact-from-nexus.sh',
    }

    file {
      '/opt/nexus-script':
        ensure => directory
    }

}
