# Resource: nexus_deploy::artifact
#
# This resource downloads Maven Artifacts from Nexus
#
# Parameters:
# [*gav*] : The artifact groupid:artifactid:version (mandatory)
# [*packaging*] : The packaging type (jar by default)
# [*classifier*] : The classifier (no classifier by default)
# [*repository*] : The repository such as 'public', 'central'...(mandatory)
# [*output*] : The output file (mandatory)
# [*ensure*] : If 'present' checks the existence of the output file (and downloads it if needed), if 'absent' deletes the output
# file, if not set redownload the artifact
# [*timeout*] : Optional timeout for download exec. 0 disables - see exec for default.
# [*owner*] : Optional user to own the file
# [*group*] : Optional group to own the file
# [*mode*] : Optional mode for file
#
# Actions:
# If ensure is set to 'present' the resource checks the existence of the file and download the artifact if needed.
# If ensure is set to 'absent' the resource deleted the output file.
# If ensure is not set or set to 'update', the artifact is re-downloaded.
#
# Sample Usage:
#  class nexus_deploy::artifact {
#   gav        => 'group:artifact:version',
#   repository => 'http://repo.url/',
#   output     => 'output file name',
# }
#
define nexus_deploy::artifact (
    $gav,
    $repository,
    $output,

    $packaging  = 'jar',
    $classifier = undef,     #$classifier = '',
    $ensure     = 'update',
    $timeout    = undef,
    $owner      = undef,
    $group      = undef,
    $mode       = '0644',    #$mode = undef,
) {

    validate_absolute_path(dirname($output))

    include nexus_deploy

    # Ensure that the download folder exists before we download stuff
    if !defined(File[dirname($output)]) {
        file {
          dirname($output):
            ensure => directory
        }
    }

    if $nexus_deploy::authentication {
        $args = "-u ${nexus_deploy::username} -p '${nexus_deploy::password}'"
    } else {
        $args = ''
    }

    if $classifier {
        $includeClass = "-c ${classifier}"
    }

    $cmd = "/opt/nexus-script/download-artifact-from-nexus.sh -a ${gav} -e ${packaging} ${includeClass} -n ${nexus_deploy::url} -r ${repository} -o ${output} ${args} -v"

    if (($ensure != absent) and ($gav =~ /-SNAPSHOT/)) {
        exec { "Checking ${gav}-${classifier}":
            command => "${cmd} -z",
            timeout => $timeout,
            before  => Exec["Download ${name}"],
        }
    }

    if $ensure == 'present' {
        exec {
          "Download ${gav}-${classifier}-${output}":
            command => $cmd,
            creates => $output,
            timeout => $timeout,
            require => File[dirname($output)]
        }
    } elsif $ensure == 'absent' {
        file {
          "Remove ${gav}-${classifier}-${output}":
            ensure => $ensure,
            path   => $output,
        }
    } else {
        exec {
          "Download ${gav}-${classifier}-${output}":
            command => $cmd,
            timeout => $timeout,
            require => File[dirname($output)]
        }
    }

    if $ensure != 'absent' {
        file {
          $output:
            ensure  => file,
            owner   => $owner,
            group   => $group,
            mode    => $mode,
            require => Exec["Download ${gav}-${classifier}-${output}"],
        }
    }
  }

}
