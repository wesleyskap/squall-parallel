require "spec_helper"

RSpec.describe Squall::Cancellation do
  let(:cancellation) { described_class.new }

  it "starts in non-cancelled state" do
    expect(cancellation.cancelled?).to be false
  end

  it "cancels atomically and notifies callbacks" do
    notified = false
    cancellation.on_cancel { notified = true }
    cancellation.cancel!

    expect(cancellation.cancelled?).to be true
    expect(notified).to be true
  end

  it "executes callback immediately if registered after cancellation" do
    cancellation.cancel!
    late_notified = false
    cancellation.on_cancel { late_notified = true }

    expect(late_notified).to be true
  end

  it "raises CancelledError on check! when cancelled" do
    cancellation.cancel!
    expect { cancellation.check! }.to raise_error(Squall::CancelledError, /cancellation token was triggered/)
  end
end
