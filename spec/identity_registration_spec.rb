# encoding: UTF-8
require_relative 'spec_helper'

describe 'openstack-orchestration::identity_registration' do
  describe 'redhat' do
    let(:runner) { ChefSpec::SoloRunner.new(REDHAT_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }

    include_context 'orchestration_stubs'

    connection_params = {
      openstack_auth_url: 'http://127.0.0.1:35357/v3/auth/tokens',
      openstack_username: 'admin',
      openstack_api_key: 'admin-pass',
      openstack_project_name: 'admin',
      openstack_domain_name: 'default'
    }
    service_name = 'heat'
    service_type = 'orchestration'
    service_user = 'heat'
    url = 'http://127.0.0.1:8004/v1/%(tenant_id)s'
    region = 'RegionOne'
    project_name = 'service'
    role_name = 'service'
    password = 'heat-pass'
    domain_name = 'Default'

    it "registers #{project_name} Project" do
      expect(chef_run).to create_openstack_project(
        project_name
      ).with(
        connection_params: connection_params
      )
    end

    it "registers #{service_name} service" do
      expect(chef_run).to create_openstack_service(
        service_name
      ).with(
        connection_params: connection_params,
        type: service_type
      )
    end

    context "registers #{service_name} endpoint" do
      %w(admin internal public).each do |interface|
        it "#{interface} endpoint with default values" do
          expect(chef_run).to create_openstack_endpoint(
            service_type
          ).with(
            service_name: service_name,
            # interface: interface,
            url: url,
            region: region,
            connection_params: connection_params
          )
        end
      end
    end

    it 'registers service user' do
      expect(chef_run).to create_openstack_user(
        service_user
      ).with(
        project_name: project_name,
        role_name: role_name,
        password: password,
        connection_params: connection_params
      )
    end

    it do
      expect(chef_run).to grant_domain_openstack_user(
        service_user
      ).with(
        domain_name: domain_name,
        role_name: role_name,
        connection_params: connection_params
      )
    end

    it do
      expect(chef_run).to grant_role_openstack_user(
        service_user
      ).with(
        project_name: project_name,
        role_name: role_name,
        password: password,
        connection_params: connection_params
      )
    end

    it 'register heat cloudformation service' do
      expect(chef_run).to create_openstack_service(
        'heat-cfn'
      ).with(
        connection_params: connection_params
      )
    end
    %w(admin internal public).each do |interface|
      it "#{interface} cloudformation endpoint with default values" do
        expect(chef_run).to create_openstack_endpoint(
          'cloudformation'
        ).with(
          service_name: 'heat-cfn',
          url: 'http://127.0.0.1:8000/v1',
          region: region,
          connection_params: connection_params
        )
      end
    end
  end
end
