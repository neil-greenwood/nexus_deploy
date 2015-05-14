# Class: nexus_deploy
#
# This module downloads Maven Artifacts from Nexus to support deployment
#
# Parameters:
# [*url*] : The Nexus base url (mandatory)
# [*repo*] : The Nexus base repository (mandatory)
# [*username*] : The username used to connect to nexus
# [*password*] : The password used to connect to nexus
#
# Actions:
# Checks and intialized the Nexus support.
#
# Sample Usage:
#  class nexus_deploy {
#   url      => http://edge.spree.de/nexus,
#   username => user,
#   password => password
#}
#
class nexus_deploy (
    $url,
    $repo,

    $username = undef,
    $password = undef,
) {
    case $::osfamily {
        'RedHat': {
        }
        'Debian','Windows','Solaris': {
            fail("${::osfamily} is not supported.")
        }
        default: {
            fail("Unknown OS ${::osfamily}.")
        }
    }

    validate_string($url)
    if empty($url) {
        fail('Mandatory parameter "url" missing.')
    }
    validate_string($repo)
    if empty($repo) {
        fail('Mandatory parameter "repo" missing.')
    }

    if((!$username and $password) or ($username and !$password)) {
        fail('Cannot initialize the Nexus class - both username and password must be set')
    }

    if $username and $password {
        $authentication = true
    } else {
        $authentication = false
    }

# Install script
    file {
      '/opt/nexus-script/download-artifact-from-nexus.sh':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template('nexus_deploy/download-artifact-from-nexus.sh.erb'),
    }

    file {
      '/opt/nexus-script/md5check.sh':
        ensure => file,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
        source => 'puppet:///modules/nexus_deploy/md5check.sh',
    }

    file {
      '/opt/nexus-script':
        ensure => directory
    }

}
