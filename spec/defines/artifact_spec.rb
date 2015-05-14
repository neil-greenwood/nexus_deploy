require 'spec_helper'

describe 'nexus_deploy::artifact', :type => :define do

    context 'with missing mandatory parameters' do
        let(:title) { 'a' }
        it { expect { should contain_define('artifact') }.to raise_error(Puppet::Error, /gav/) }
    end

    context 'downloading junit jar' do
        let(:facts) {{
            :operatingsystemrelease => '6',
            :osfamily               => 'RedHat',
        }}
        let(:title) { 'junit' }
        let(:pre_condition) { ['class {"nexus_deploy":', ' url => "foo",', '}'] }
        let(:params) {{
            :gav        => 'junit:junit:4.11',
            :repository => 'public',
            :output     => '/foo/bar/junit-4.11.jar',
        }}

        it { should contain_file('/foo/bar').with_ensure('directory') }
        it { should contain_exec('Download junit:junit:4.11--/foo/bar/junit-4.11.jar').with(
            'command' => '/opt/nexus-script/download-artifact-from-nexus.sh -a junit:junit:4.11 -e jar  -n foo -r public -o /foo/bar/junit-4.11.jar  -v',
        ).that_requires('File[/foo/bar]') }
        it { should contain_file('/foo/bar/junit-4.11.jar').with(
            'ensure'  => 'file',
            'mode'    => '0644',
        ).that_requires('Exec[Download junit:junit:4.11--/foo/bar/junit-4.11.jar]')
        }
    end
end
