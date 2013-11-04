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
define nexus_deploy::artifact(
	$gav,
	$packaging = "jar",
	$classifier = "",
	$repository,
	$output,
	$ensure = update,
	$timeout = undef,
  $owner = undef,
  $group = undef,
  $mode = undef
	) {
	
	include nexus_deploy
	
	if ($nexus_deploy::authentication) {
		$args = "-u ${nexus_deploy::user} -p '${nexus_deploy::pwd}'"
	} else {
		$args = ""
	}

	if ($classifier) {
		$includeClass = "-c ${classifier}"	
	}

	$cmd = "/opt/nexus-script/download-artifact-from-nexus.sh -a ${gav} -e ${packaging} $includeClass -n ${nexus_deploy::NEXUS_URL} -r ${repository} -o ${output} $args -v"
	
	if $ensure == present {
		exec { "Download ${gav}-${classifier}":
			command => $cmd,
			creates  => "${output}",
			timeout => $timeout
		}
	} elsif $ensure == absent {
		file { "Remove ${gav}-${classifier}":
			path   => $output,
			ensure => absent
		}
	} else {
		exec { "Download ${gav}-${classifier}":
			command => $cmd,
			timeout => $timeout
		}
	}

    if $ensure != absent {
      file { "${output}":
        ensure => file,
        require => Exec["Download ${gav}-${classifier}"],
        owner => $owner,
        group => $group,
        mode => $mode
      }
    }

}
