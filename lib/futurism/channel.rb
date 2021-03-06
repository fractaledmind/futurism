module Futurism
  class Channel < ActionCable::Channel::Base
    include CableReady::Broadcaster

    def subscribed
      stream_from "Futurism::Channel"
    end

    def receive(data)
      resources = data["signed_params"].map { |signed_params|
        [signed_params, Rails.application.message_verifier("futurism").verify(signed_params)]
      }

      ApplicationController.renderer.instance_variable_set(:@env, connection.env)

      resources.each do |signed_params, resource|
        cable_ready["Futurism::Channel"].outer_html(
          selector: "[data-signed-params='#{signed_params}']",
          html: ApplicationController.render(resource)
        )
      end

      cable_ready.broadcast
    end
  end
end
