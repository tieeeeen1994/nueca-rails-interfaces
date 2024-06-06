# frozen_string_literal: true

raise 'Rails not found' unless defined?(Rails)

require 'to_bool'

require_relative 'rails_interfaces/version'

module Nueca
  # This module is a namespace for the RailsInterfaces module.
  module RailsInterfaces
  end
end

require_relative 'rails_interfaces/util'

# Require all interfaces.
Dir["#{__dir__}/../v*/*.rb"].each { |file| require_relative file }
