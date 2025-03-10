# frozen_string_literal: true

require_relative 'lib/nueca_rails_interfaces/version'

Gem::Specification.new do |spec|
  spec.name = 'nueca_rails_interfaces'
  spec.version = NuecaRailsInterfaces::VERSION
  spec.authors = ['Tien']
  spec.email = ['tieeeeen1994@gmail.com']
  spec.summary = 'Interfaces for known object entities in Rails Development at Nueca.'
  spec.homepage = 'https://github.com/tieeeeen1994/nueca-rails-interfaces'
  spec.required_ruby_version = '>= 3.3.0'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .gitlab-ci.yml appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'rails', '>= 7', '< 9'
  spec.add_dependency 'to_bool', '~> 2.1'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.license = 'MIT'
end
