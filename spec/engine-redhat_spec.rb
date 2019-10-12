# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-orchestration::engine' do
  describe 'redhat' do
    let(:runner) { ChefSpec::SoloRunner.new(REDHAT_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }

    include_context 'orchestration_stubs'
    include_examples 'expect runs openstack orchestration common recipe'

    it 'installs heat engine package' do
      expect(chef_run).to upgrade_package 'openstack-heat-engine'
    end

    it 'enables heat engine on boot' do
      expect(chef_run).to enable_service('openstack-heat-engine')
    end

    it 'starts heat engine on boot' do
      expect(chef_run).to start_service('openstack-heat-engine')
    end
  end
end
