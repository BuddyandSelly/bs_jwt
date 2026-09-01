# frozen_string_literal: true

require 'rake'

##
# The gem ships a rake task that Rails picks up through the railtie.
#
# `Kernel#load` resets the coverage counters of the file it loads, so the task
# definition is loaded exactly once for the whole suite.
module RakeHelpers
  def install_task
    RakeHelpers.install_task
  end

  def self.install_task
    @install_task ||= begin
      # rake only records descriptions when it is asked to list tasks
      Rake::TaskManager.record_task_metadata = true
      load 'bs_jwt/tasks/install.rake'
      Rake::Task['bs_jwt:install']
    end
  end
end
