# frozen_string_literal: true

##
# Minimal stand-in for the parts of Rails the gem talks to. `Rails::Railtie`
# only has to accept and expose the `rake_tasks` block a railtie registers.
module RailsStandIn
  class Railtie
    def self.rake_tasks(&block)
      rake_task_blocks << block
    end

    def self.rake_task_blocks
      @rake_task_blocks ||= []
    end
  end
end
