require 'file_system'

class FileManagerController < ApplicationController
  # GET /fs*path
  def index
    path = Pathname.new(absolute_requested_path)

    if path.directory?
      @fs_entries = FileSystem::Operation.new.list(absolute_requested_path).map do |path|
          FileSystem::Entry.from_pathname(path)
      end
    else
      send_file(path, disposition: 'inline')
    end
  end

  # GET /fs/show/*path
  def show
    @entry = FileSystem::Entry.from_pathname(Pathname.new(absolute_requested_path))
  end

  # GET /fs/copy?source=...&destination=...&return=...
  def copy
    # TODO: start an ActiveJob to handle the copy
    redirect_to action: 'index', path: return_path, flash: { :error => "Pretending to copy #{source_path} to #{destination_path}" }
  end

  def move
  end

  def rename
  end

  def delete
  end

  def download
    path = Pathname.new(absolute_requested_path)

    if path.directory?
      # TODO: start ActiveJob to compress directory, then start download?
    else
      send_file(path, disposition: 'inline')
    end
  end

  # POST /fs/upload/*path
  def upload
  end

  private

  def absolute_requested_path
    '/' + params.fetch('path', '').to_s
  end
  helper_method :absolute_requested_path

  def source_path
    params['source']
  end

  def destination_path
    params['destination']
  end

  def return_path
    params['return']
  end
end
