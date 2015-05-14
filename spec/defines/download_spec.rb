require 'spec_helper'

describe 'nexus_deploy::download', :type => :define do

    context 'with missing mandatory parameters' do
        let(:title) { 'a' }

        it { expect { should contain_define('download') }.to raise_error(Puppet::Error, /groupid/) }
    end

    context 'downloading junit jar' do
        let(:facts) {{
            :operatingsystemrelease => '6',
            :osfamily               => 'RedHat',
        }}
        let(:title) { 'junit' }
        let(:pre_condition) { ['class {"nexus_deploy":',
                               ' url  => "http://nexus-repo/nexus",',
                               ' repo => "releases",',
                               '}'] }
        let(:params) {{
            :groupid    => 'junit',
            :artifactid => 'junit',
            :version    => '4.11',
            :repository => 'public',
            :output     => '/foo/bar/junit-4.11.jar',
        }}

        it { should contain_file('/foo/bar').with_ensure('directory') }
        it { should contain_nexus_deploy__artifact('Downloading artifact: junit.jar to /foo/bar/junit-4.11.jar') }
        it { should contain_nexus_deploy__artifact('Downloading checksum: junit.jar.md5 to /foo/bar/junit-4.11.jar.md5') }
        it { should contain_exec('Checking checksum: /foo/bar/junit-4.11.jar') }
    end
end
