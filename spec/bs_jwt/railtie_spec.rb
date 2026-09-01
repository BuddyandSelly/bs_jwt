# frozen_string_literal: true

RSpec.describe 'the railtie' do
  # `BsJwt` itself is loaded without Rails being present, so the railtie has to
  # be required explicitly. `require` is idempotent, which keeps the railtie
  # from being re-evaluated for every example.
  before do
    stub_const('Rails::Railtie', RailsStandIn::Railtie)
    require 'bs_jwt/railtie'
  end

  it 'is a Rails railtie' do
    expect(BsJwt::Railtie.superclass).to be(RailsStandIn::Railtie)
  end

  it 'registers the rake tasks of the gem' do
    expect(BsJwt::Railtie).to receive(:load).with('bs_jwt/tasks/install.rake')

    BsJwt::Railtie.rake_task_blocks.each(&:call)
  end

  it 'registers exactly one rake task block' do
    expect(BsJwt::Railtie.rake_task_blocks.size).to eq(1)
  end
end
