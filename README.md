Puppet Module for Nexus
=======================

This Puppet Module downloads Maven artifacts from a Nexus server. It supports:

* artifact identification using GAV classifier and packaging
* repository selection
* authentication
* comparing artifact hash againts nexus generated one  

It relies on the Nexus REST service and on curl.

Getting the module
------------------

* Clone this repository and add it to your _modulepath_

Requirements
------------

* puppetlabs/stdlib - https://forge.puppetlabs.com/puppetlabs/stdlib

Usage
-----

    # Initialize Nexus
    class {
      'nexus_deploy':
        url      => 'http://edge.spree.de/nexus',
        username => 'nexus',
        password => '********',
    }

    nexus_deploy::artifact {
      'commons-io':
        gav        => "commons-io:commons-io:2.1',
        repository => 'public',
        output     => 'tmp/commons-io-2.1.jar',
    }

    nexus_deploy::artifact {
      'ipojo':
        gav        => 'org.apache.felix:org.apache.felix.ipojo:1.8.0',
        repository => 'public',
        output     => '/tmp/ipojo-1.8.jar',
    }

    nexus_deploy::artifact {
      'chameleon web distribution':
        gav        => 'org.ow2.chameleon:distribution-web:0.3.0-SNAPSHOT',
        classifier => 'distribution',
        packaging  => 'zip',
        repository => 'public-snapshots',
        output     => '/tmp/distribution-web-0.3.0-SNAPSHOT.zip',
        timeout    => 600,
        owner      => 'myuser',
        group      => 'mygroup',
        mode       => 0755,
    }


License
-------

This project is licensed under the Apache Software License 2.0.
