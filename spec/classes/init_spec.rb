require 'spec_helper'

describe 'nexus_deploy' do

    context 'with missing mandatory parameter' do
        it { expect { should contain_package('nexus_deploy') }.to raise_error(Puppet::Error, /url/) }
    end

    context 'with defaults for all parameters, RHEL 5' do
        let(:facts) {{
            :osfamily => 'RedHat',
            :operatingsystemrelease => '5',
        }}
        let(:params) {{
            :url => 'foo',
        }}
        it { should contain_class('nexus_deploy') }

        # check copied files
        it { should contain_file('/opt/nexus-script/download-artifact-from-nexus.sh').with(
                'ensure' => 'file',
                'owner'  => 'root',
                'group'  => 'root',
                'mode'   => '0755',
            )
        }
        it { should contain_file('/opt/nexus-script/md5check.sh').with(
                'ensure' => 'file',
                'owner'  => 'root',
                'group'  => 'root',
                'mode'   => '0755',
            )
        }
        it { should contain_file('/opt/nexus-script').with_ensure('directory') }
    end

    context 'with defaults for all parameters, RHEL 6' do
        let(:facts) {{
            :osfamily => 'RedHat',
            :operatingsystemrelease => '6',
        }}
        let(:params) {{
            :url => 'foo',
        }}
        it { should contain_class('nexus_deploy') }

        # check copied files
        it { should contain_file('/opt/nexus-script/download-artifact-from-nexus.sh').with(
                'ensure' => 'file',
                'owner'  => 'root',
                'group'  => 'root',
                'mode'   => '0755',
            )
        }
        it { should contain_file('/opt/nexus-script/md5check.sh').with(
                'ensure' => 'file',
                'owner'  => 'root',
                'group'  => 'root',
                'mode'   => '0755',
            )
        }
        it { should contain_file('/opt/nexus-script').with_ensure('directory') }
    end

    context 'supported operating systems' do
        # Loop through different operating systems
        ['RedHat'].each do |osfamily|
            describe "nexus_deploy class with mandatory parameters on #{osfamily}" do
                let(:params) {{
                    :url => 'foo',
                }}
                let(:facts) {{
                    :osfamily => osfamily,
                }}

                it { should compile.with_all_deps }
                it { should contain_class('nexus_deploy') }
            end
        end
    end

    context 'unsupported operating systems' do
        # Loop through different operating systems
        ['Debian', 'Solaris', 'Windows'].each do |osfamily|
            describe "nexus_deploy class with mandatory parameters on #{osfamily}" do
                let(:params) {{
                    :url => 'foo',
                }}
                let(:facts) {{
                    :osfamily => osfamily,
                }}

                it { expect { should contain_package('nexus_deploy') }.to raise_error(Puppet::Error, /#{osfamily} is not supported/) }
            end
        end
    end

end
