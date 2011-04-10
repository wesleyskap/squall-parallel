require "spec_helper"

RSpec.describe Squall::RailsAdapter do
  it "gracefully yields when ActiveRecord is not defined" do
    yielded = false
    Squall::RailsAdapter.with_connection { yielded = true }
    expect(yielded).to be true
  end
end
