# Resource: nexus_deploy::artifact
#
# This resource downloads Maven Artifacts from Nexus
#
# Parameters:
# [*groupid*] : The artifact groupid (mandatory)
# [*artifactid*] : The artifact artifactid (mandatory)
# [*version*] : The artifact version (mandatory)
# [*repository*] : The repository such as 'public', 'central'...(mandatory)
# [*output*] : The output file (mandatory)
# [*packaging*] : The packaging type (jar by default)
# [*classifier*] : The classifier (no classifier by default)
# [*ensure*] : If 'present' checks the existence of the output file (and downloads it if needed), if 'absent' deletes the output file, if not set redownload the artifact
# [*timeout*] : Optional timeout for download exec. 0 disables - see exec for default.
# [*owner*] : Optional owner to own the file
# [*group*] : Optional group to own the file
# [*mode*] : Optional mode for file
# [*link_folder*] : Optional folder, where symlink of the current artifact will be created. Must be set when $link_create is set to true
# [*link_create*] : Usefull when we want to remove the symlink wihtout rebuiling the env (or removing by hand)
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
define nexus_deploy::download (
    $groupid,
    $artifactid,
    $version,
    $repository,

    $output,

    $packaging   = 'jar',
    $classifier  = undef,
    $ensure      = 'update',

    $timeout     = undef,

    $owner       = undef,
    $group       = undef,
    $mode        = '0644',

    $link_folder = undef,
    $link_create = false,

    $checksum    = 'md5',
) {

    validate_bool($link_create)

    if $link_create and !$link_folder {
        fail('$link_folder must be set, if $link_create is true.')
    }

    nexus_deploy::artifact {
      "Downloading artifact: ${artifactid}.${packaging}":
        ensure     => $ensure,
        gav        => "${groupid}:${artifactid}:${version}",
        repository => $repository,
        classifier => $classifier,
        packaging  => $packaging,
        output     => $output,
        owner      => $owner,
        group      => $group,
        mode       => $mode,
    }

    if $checksum {
        nexus_deploy::artifact {
          "Downloading checksum: ${artifactid}.${packaging}.${checksum}":
            ensure     => $ensure,
            gav        => "${groupid}:${artifactid}:${version}",
            repository => $repository,
            classifier => $classifier,
            packaging  => "${packaging}.${checksum}",
            output     => "${output}.${checksum}",
            owner      => $owner,
            group      => $group,
            mode       => $mode,
        }

        exec {
          "Checking checksum: ${output}":
            cwd     => dirname($output),
            command => "/opt/nexus-script/md5check.sh ${output}.${checksum}",
            refreshonly => true,
            require => [
                Nexus_deploy::Artifact["Downloading artifact: ${artifactid}.${packaging}"],
                Nexus_deploy::Artifact["Downloading checksum: ${artifactid}.${packaging}.${checksum}"],
            ],
        }
    }

    if $link_folder {

        validate_absolute_path($link_folder)

        $symlink = "${link_folder}/${artifactid}.${packaging}"

        if $link_create {
            file {
              $symlink:
                ensure => link,
                target => $output,

            }
        } else {
            file {
              $symlink:
                ensure => absent,
            }
        }
    }
}
