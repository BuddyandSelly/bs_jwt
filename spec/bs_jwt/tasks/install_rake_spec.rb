# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

RSpec.describe 'the bs_jwt:install rake task' do
  subject(:task) { install_task }

  let(:gem_root) { File.expand_path('../../..', __dir__) }
  let(:template) { File.join(gem_root, 'config', 'initializers', 'bs_jwt.rb') }
  let(:rails_root) { Dir.mktmpdir }
  let(:initializer) { File.join(rails_root, 'config', 'initializers', 'bs_jwt.rb') }

  after { FileUtils.remove_entry(rails_root) }

  it 'is described' do
    expect(task.full_comment).to eq('Stub an initializer for BS::JWT configuration.')
  end

  context 'invoked outside of a Rails application' do
    it 'raises an error' do
      expect { task.execute }.to raise_exception(RuntimeError, 'Rails not loaded!')
    end
  end

  context 'invoked inside a Rails application' do
    before do
      stub_const('Rails', double('Rails', root: rails_root))
      allow(Gem).to receive(:loaded_specs)
        .and_return(Gem.loaded_specs.merge('bs_jwt' => instance_double(Gem::Specification,
                                                                       full_gem_path: gem_root)))
      FileUtils.mkdir_p(File.dirname(initializer))
    end

    context 'without an existing initializer' do
      it 'copies the initializer template into the application' do
        expect { task.execute }
          .to output(/Generating new initializer at #{Regexp.escape(initializer)}/)
          .to_stdout_from_any_process

        expect(File.read(initializer)).to eq(File.read(template))
      end
    end

    context 'with an existing initializer' do
      before { File.write(initializer, '# a previously generated initializer') }

      it 'overwrites the existing initializer' do
        expect { task.execute }
          .to output(/File #{Regexp.escape(initializer)} exists, overwriting/)
          .to_stdout_from_any_process

        expect(File.read(initializer)).to eq(File.read(template))
      end
    end
  end
end
