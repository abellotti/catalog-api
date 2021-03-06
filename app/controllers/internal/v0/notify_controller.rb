module Internal
  module V0
    class NotifyController < ::ApplicationController
      skip_before_action :validate_primary_collection_id
      self.openapi_enabled = false

      def notify_approval_request
        request_id = params.require(:request_id)
        payload = params.require(:payload)
        message = params.require(:message)

        ActsAsTenant.without_tenant do
          Catalog::NotifyApprovalRequest.new(request_id, payload, message).process
        end
        json_response(nil)
      end

      def notify_task
        task_id = params.require(:task_id)
        payload = params.require(:payload)
        message = params.require(:message)

        topic = OpenStruct.new(:payload => payload.merge("task_id" => task_id), :message => message)
        ActsAsTenant.without_tenant do
          Catalog::DetermineTaskRelevancy.new(topic).process
        end

        json_response(nil)
      end
    end
  end
end
