# frozen_string_literal: true

require 'test_helper'

# Progress must describe completed copy work, including hidden files and links.
class PosixTransferProgressTest < ActiveSupport::TestCase
  def with_copy
    Dir.mktmpdir do |dir|
      source = Pathname.new(dir).join('source')
      source.mkpath
      yield source, Pathname.new(dir).join('destination')
    end
  end

  def perform_copy(source, destination)
    transfer = PosixTransfer.build(action: 'cp', files: { source.to_s => destination.to_s })
    percentages = []
    transfer.define_singleton_method(:percent=) do |value|
      percentages << value
      @percent = value
    end
    transfer.perform
    assert transfer.success?, transfer.errors.full_messages.inspect
    assert percentages.all? { |value| (0..100).cover?(value) }, percentages.inspect
    assert_equal 100, transfer.percent
    transfer
  end

  test 'creating a destination parent is not an extra copy item' do
    with_copy do |source, destination|
      source.join('one').write('payload')
      perform_copy(source, destination)
      assert_equal 'payload', destination.join('one').read
    end
  end

  test 'empty directories report completion only after being created' do
    with_copy do |source, destination|
      transfer = PosixTransfer.build(action: 'cp', files: { source.to_s => destination.to_s })
      assert_equal 1, transfer.steps
      transfer.expects(:percent=).with do |percent|
        percent == 100 && destination.directory?
      end.once
      transfer.perform
      assert transfer.success?
    end
  end

  test 'a directory symlink counts as one item and is copied as a link' do
    with_copy do |source, destination|
      source.join('one').write('one')
      source.join('two').write('two')
      link = source.parent.join('link')
      link.make_symlink(source)
      transfer = PosixTransfer.build(action: 'cp', files: { link.to_s => destination.to_s })
      assert_equal 1, transfer.steps
      perform_copy(link, destination)
      assert destination.symlink?
      assert_equal source, destination.readlink
    end
  end

  test 'progress remains bounded if a source grows after it is counted' do
    with_copy do |source, destination|
      source.join('one').write('one')
      transfer = PosixTransfer.build(action: 'cp', files: { source.to_s => destination.to_s })
      assert_equal 1, transfer.steps
      source.join('two').write('two')
      percentages = []
      transfer.define_singleton_method(:percent=) do |value|
        percentages << value
        @percent = value
      end
      transfer.perform
      assert transfer.success?
      assert percentages.all? { |value| value <= 100 }, percentages.inspect
      assert_equal 'two', destination.join('two').read
    end
  end

  test 'an inaccessible source does not prevent copying other sources' do
    with_copy do |source, destination|
      blocked = source.join('blocked')
      blocked.mkpath
      source.join('one').write('one')
      # Fail both counting and copying this directory without relying on uid.
      Pathname.any_instance.stubs(:children).raises(Errno::EACCES)
      Pathname.any_instance.stubs(:empty?).raises(Errno::EACCES)
      transfer = PosixTransfer.build(
        action: 'cp',
        files:  { blocked.to_s            => destination.join('blocked').to_s,
                  source.join('one').to_s => destination.join('one').to_s }
      )
      transfer.perform
      refute transfer.success?
      assert_equal 1, transfer.errors.count
      assert_equal 'one', destination.join('one').read
    end
  end
end
