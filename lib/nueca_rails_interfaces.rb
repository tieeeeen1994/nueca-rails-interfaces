# frozen_string_literal: true

raise 'Rails not found' unless defined?(Rails)

require 'to_bool'

require_relative 'nueca_rails_interfaces/version'

# This module is a namespace for the gem.
module NuecaRailsInterfaces
end

require_relative 'nueca_rails_interfaces/util'

# Require all interfaces.
Dir["#{__dir__}/v*/*_interface.rb"].each { |file| require_relative file }
