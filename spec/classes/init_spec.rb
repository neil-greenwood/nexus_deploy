require 'spec_helper'

describe 'nexus_deploy' do

    context 'with missing mandatory parameter' do
        it { expect { should contain_package('nexus_deploy') }.to raise_error(Puppet::Error, /url/) }
    end

    ['5','6'].each do |osrelease|
        context "with defaults for all parameters, RHEL #{osrelease}" do
            let(:facts) {{
                :osfamily               => 'RedHat',
                :operatingsystemrelease => osrelease,
            }}
            let(:params) {{
                :url  => 'http://nexus-repo:8081/nexus',
                :repo => 'public-repo',
            }}
            it { should contain_class('nexus_deploy') }

            # check copied files
            it { should contain_file('/opt/nexus-script/download-artifact-from-nexus.sh').with(
                    'ensure' => 'file',
                    'owner'  => 'root',
                    'group'  => 'root',
                    'mode'   => '0755',
                ).with_content(%r{^NEXUS_BASE=http://nexus-repo:8081/nexus})
                 .with_content(%r{^REPO=public-repo})
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
    end

    context 'supported operating systems' do
        # Loop through different operating systems
        ['RedHat'].each do |osfamily|
            describe "nexus_deploy class with mandatory parameters on #{osfamily}" do
                let(:params) {{
                    :url  => 'foo',
                    :repo => 'repo',
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
                    :url  => 'foo',
                    :repo => 'repo',
                }}
                let(:facts) {{
                    :osfamily => osfamily,
                }}

                it { expect { should contain_package('nexus_deploy') }.to raise_error(Puppet::Error, /#{osfamily} is not supported/) }
            end
        end
    end

end
