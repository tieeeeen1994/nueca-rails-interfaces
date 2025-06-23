# frozen_string_literal: true

raise 'Rails not found' unless defined?(Rails)

require 'to_bool'

require_relative 'nueca_rails_interfaces/version'

# This module is a namespace for the gem.
module NuecaRailsInterfaces
  # Class that forces an error due to being deprecated.
  class DeprecatedError < StandardError
    def initialize
      super('This feature is deprecated.')
    end
  end
end

require_relative 'nueca_rails_interfaces/util'

# Require all interfaces.
Dir["#{__dir__}/nueca_rails_interfaces/v*/**/*_interface.rb"].each { |file| require_relative file }
