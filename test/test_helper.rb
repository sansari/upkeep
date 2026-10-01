ENV["RAILS_ENV"] ||= "test"
ENV["UPKEEP_PASSWORD"] = "test-password"
require_relative "../config/environment"
require "rails/test_help"

module AuthenticationTestHelper
  def sign_in
    post session_path, params: { password: ENV.fetch("UPKEEP_PASSWORD") }
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
  end
end

class ActionDispatch::IntegrationTest
  include AuthenticationTestHelper
end
