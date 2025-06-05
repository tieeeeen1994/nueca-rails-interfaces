# frozen_string_literal: true

RSpec.describe NuecaRailsInterfaces do
  it 'has a version number' do
    expect(NuecaRailsInterfaces::VERSION).not_to be_nil
  end

  context 'when one of the deprecated interfaces is used' do
    let(:klass) do
      deprecated_interface = Module.new do
        def self.included(_)
          raise NuecaRailsInterfaces::DeprecatedError
        end
      end
      Class.new do
        include deprecated_interface
      end
    end

    it 'raises an error if one of the deprecated interfaces is used' do
      expect { klass }.to raise_error(NuecaRailsInterfaces::DeprecatedError, 'This feature is deprecated.')
    end
  end
end
