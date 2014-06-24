# Class: nexus_deploy::hiera
#
# This class takes hashes from hiera and sends them to nexus_deploy::artifacts define
#
# Parameters:
# [*nexus_deploy*] : Hashed values from hiera
#
# Sample Usage:
#  include nexus_deploy::hiera
#
class nexus_deploy::hiera ($nexus_deploy = hiera_hash(nexus_deploy)) {

    require nexus_deploy

    create_resources(nexus_deploy::artifact, $nexus_deploy)
}