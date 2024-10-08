module Actions
  module Pulp3
    module ContentView
      class DeleteRepositoryReferences < Pulp3::AbstractAsyncTask
        def plan(content_view, smart_proxy)
          if content_view.repository_references.any?
            plan_self(:content_view_id => content_view.id, :smart_proxy_id => smart_proxy.id)
          end
        end

        def invoke_external_task
          tasks = []
          content_view = ::Katello::ContentView.find(input[:content_view_id])
          to_delete = content_view.repository_references.select do |repository_reference|
            repo = repository_reference.root_repository.library_instance
            if delete_href?(repository_reference.repository_href, content_view)
              if repo.root.is_container_push?
                tasks << repo.backend_service(smart_proxy).delete_distributions
              else
                tasks << repo.backend_service(smart_proxy).delete_repository(repository_reference)
              end
              true
            else
              false
            end
          end
          to_delete.each(&:destroy)

          output[:pulp_tasks] = tasks.compact
        end

        #migrated composites may have the same RepositoryReference as their component
        def delete_href?(href, content_view)
          ::Katello::Pulp3::RepositoryReference.where(:repository_href => href).where.not(:content_view_id => content_view.id).empty?
        end
      end
    end
  end
end
