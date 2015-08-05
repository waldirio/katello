require 'katello_test_helper'
require 'support/pulp/repository_support'

module Katello
  class GluePulpPuppetModuleTest < ActiveSupport::TestCase
    def setup
      set_user
      configure_runcible

      VCR.insert_cassette('glue_pulp_puppet_module')

      @repository = Repository.find(katello_repositories(:p_forge))
      RepositorySupport.create_and_sync_repo(@repository)

      @names = ["cron", "httpd", "pureftpd", "samba"]
    end

    def teardown
      RepositorySupport.destroy_repo
      VCR.eject_cassette
    end

    def test_repo_puppet_modules
      assert_equal 4, @repository.puppet_modules.length
      assert_equal @names, @repository.puppet_modules.map(&:name).sort
    end

    def test_puppet_module_attributes
      puppet_module = @repository.puppet_modules.sort_by(&:name).first
      assert_equal "cron", puppet_module.name
      assert_equal "5UbZ3r0", puppet_module.author # very 1337
      assert_equal "0.0.1", puppet_module.version
    end

    def test_cloned_puppet_modules
      @dev_repo = Repository.find(katello_repositories(:dev_p_forge))
      @dev_repo.relative_path = "/test_path/"
      @dev_repo.create_pulp_repo

      Katello.pulp_server.extensions.puppet_module.expects(:copy).
        with(@repository.pulp_id, @dev_repo.pulp_id)
      tasks = @repository.clone_contents(@dev_repo)
      TaskSupport.wait_on_tasks(tasks)

      assert_equal 4, @repository.puppet_modules.length
      assert_equal @names, @repository.puppet_modules.map(&:name).sort
    ensure
      RepositorySupport.destroy_repo(@dev_repo.pulp_id)
    end

    def test_generate_unit_data
      path = File.join(Katello::Engine.root, "test/fixtures/puppet/puppetlabs-ntp-2.0.1.tar.gz")
      unit_key, unit_metadata = PuppetModule.generate_unit_data(path)

      assert_equal "puppetlabs", unit_key["author"]
      assert_equal "ntp", unit_key[:name]

      assert_equal [], unit_metadata[:tag_list]
      assert_nil unit_metadata[:name]
      assert_nil unit_metadata[:author]
    end
  end
end
