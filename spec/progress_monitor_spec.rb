# frozen_string_literal: true

require "spec_helper"

RSpec.describe Squall::ProgressMonitor do
  it "calculates completion percentage and eta" do
    monitor = Squall::ProgressMonitor.new(100)
    expect(monitor.percent_complete).to eq(0.0)

    10.times { monitor.increment }
    expect(monitor.percent_complete).to eq(10.0)
    expect(monitor.processed).to eq(10)
  end
end
