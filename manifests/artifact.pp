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
# [*ensure*] : If 'present' checks the existence of the output file (and downloads it if needed), if 'absent' deletes the output file, if not set redownload the artifact
# [*timeout*] : Optional timeout for download exec. 0 disables - see exec for default.
# [*owner*] : Optional user to own the file
# [*group*] : Optional group to own the file
# [*mode*] : Optional mode for file
# [*checksum*] : Compare hash of downloaded artifact again nexus generated one. Currently only md5 is available
#
# Actions:
# If ensure is set to 'present' the resource checks the existence of the file and download the artifact if needed.
# If ensure is set to 'absent' the resource deleted the output file.
# If ensure is not set or set to 'update', the artifact is re-downloaded.
#
# Sample Usage:
#  class nexus_deploy {
#   url => http://edge.spree.de/nexus,
#   username => user,
#   password => password
# }
#
define nexus_deploy::artifact (
    $gav,
    $repository,
    $output,

    $packaging  = 'jar',
    $classifier = undef,
    $ensure     = 'update',
    $timeout    = undef,
    $owner      = undef,
    $group      = undef,
    $mode       = '0644',
    $checksum   = 'md5',
) {

    include nexus_deploy

    if $nexus_deploy::authentication {
        $args = "-u ${nexus_deploy::username} -p '${nexus_deploy::password}'"
    } else {
        $args = ''
    }

    if $classifier or $classifier == '' {
        $includeClass = "-c ${classifier}"
    }

    each([$output, $checksum])  |$index, $value| {

        if $index == 0 {
            $output_real    = $output
            $packaging_real = $packaging
        } else {
            $output_real    = "${output}.${checksum}"
            $packaging_real = "${packaging}.${checksum}"
        }

        $cmd = "/opt/nexus-script/download-artifact-from-nexus.sh -a ${gav} -e ${packaging_real} ${includeClass} -n ${nexus_deploy::url} -r ${repository} -o ${output_real} ${args} -v"

        if $ensure == 'present' {
            exec {
              "Download ${gav}-${classifier}-${output_real}":
                command => $cmd,
                creates => $output_real,
                timeout => $timeout,
                notify  => Exec["Checking checksum for ${output}"],
            }
        } elsif $ensure == 'absent' {
            file {
              "Remove ${gav}-${classifier}-${output_real}":
                ensure => $ensure,
                path   => $output_real,
            }
        } else {
            exec {
              "Download ${gav}-${classifier}-${output_real}":
                command => $cmd,
                timeout => $timeout,
                notify  => Exec["Checking checksum for ${output}"],
            }
        }

        if $ensure != absent {
            file {
              $output_real:
                ensure  => file,
                owner   => $owner,
                group   => $group,
                mode    => $mode,
                require => Exec["Download ${gav}-${classifier}-${output_real}"],
            }
        }
    }

## Do checksum
    exec {
      "Checking checksum for ${output}":
        cwd         => dirname($output),
        command     => "/opt/nexus-script/md5check.sh ${output}.${checksum}",
        refreshonly => true,
    }

}
