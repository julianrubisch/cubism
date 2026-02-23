# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
require "rails/test_help"
require "mocha/minitest"

# Load fixtures from the engine
fixtures_path = File.expand_path("dummy/test/fixtures", __dir__)

if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths = [fixtures_path]
  ActionDispatch::IntegrationTest.fixture_paths = ActiveSupport::TestCase.fixture_paths if ActionDispatch::IntegrationTest.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.file_fixture_path = "#{fixtures_path}/files"
  ActiveSupport::TestCase.fixtures :all
elsif ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = fixtures_path
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path if ActionDispatch::IntegrationTest.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.file_fixture_path = "#{fixtures_path}/files"
  ActiveSupport::TestCase.fixtures :all
end
