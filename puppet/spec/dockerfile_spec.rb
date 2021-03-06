require 'spec_helper'

DOCKER_IMAGE_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include Vtasks::Docker::SharedContext::Container

  it 'uses the correct version of Ubuntu' do
    os_version = command('cat /etc/lsb-release').stdout
    expect(os_version).to include('16.04')
    expect(os_version).to include('Ubuntu')
  end

  describe package('puppet-agent') do
    it { is_expected.to be_installed }
  end

  describe command('puppet --version') do
    its(:stdout) { is_expected.to contain('.') }
    its(:exit_status) { is_expected.to eq 0 }
  end
end
