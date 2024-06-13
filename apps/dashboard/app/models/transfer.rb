# frozen_string_literal: true

# Parent ActiveModel class for transfer files.
class Transfer
  include ActiveModel::Model
  include ActiveModel::Validations
  include GlobalID::Identification

  # for progress tracking and retrieval
  attr_accessor :id, :status, :created_at, :started_at, :completed_at
  attr_writer :percent

  def percent
    status&.completed? ? 100 : (@percent || 0)
  end

  attr_accessor :exit_status, :stderr, :pid

  # files could either be an array of strings or an array of hashes (string=>string)
  attr_accessor :action, :files

  REMOVE_ACTION = 'rm'
  COPY_ACTION   = 'cp'
  MOVE_ACTION   = 'mv'

  class << self
    def transfers
      @transfers ||= []
    end

    def find(id)
      transfers.find { |t| t.id == id }
    end
  end

  def bootstrap_class
    # TODO: if error occurs, need to display error label! (and pop error alert above page)
    if status&.completed?
      'success'
    elsif status&.running?
      'info'
    else
      'default'
    end
  end

  def fa_label
    if status&.completed?
      'fa-check'
    elsif status&.running?
      'fa-spinner fa-spin'
    else
      'fa-pause'
    end
  end

  def action_title
    t = status&.queued? ? 'waiting to ' : ''

    case action
    when 'mv'
      "#{t}move files"
    when 'rm'
      "#{t}remove files"
    when 'cp'
      "#{t}copy files"
    else
      t + "#{action} files"
    end
  end

  def to_s
    "#{percent}% #{action_title}"
  end

  # we use GlobalID::Identification so that TransferLocalJob is very simple and knows how to find the object
  # https://dev.mikamai.com/2014/09/01/rails-42-new-gems-active-job-and-global-id/

  def save
    # save has no effect if already persisted because this is in memory
    # if we change the storage, we change this method
    unless persisted?
      # HACK: we use the id as a dom id as well, so it is beneficial to have this be compatible HTML ID
      # if the id doesn't start with a letter, it can cause problems with Bootstrap 4 sometimes
      self.id = "t#{SecureRandom.uuid}"
      self.status = OodCore::Job::Status.new(state: :queued)
      self.created_at = Time.now.to_i

      self.class.transfers << self
    end
  end

  def cancelable?
    pid && !completed?
  end

  def cancel
    Process.kill('TERM', pid) if status.running? && pid
  end

  def steps
    0
  end

  def persisted?
    !id.nil?
  end

  def command_str
    commands.map { |v| v.join(' ') }.join('; ')
  end

  def update_percent(step)
    self.percent = steps.zero? ? 100 : (100.0 * (step.to_f / steps)).to_i
  end

  def perform_later
    save
    TransferLocalJob.perform_later(self)
  end

  def remove?
    action == Transfer::REMOVE_ACTION
  end

  def copy?
    action == Transfer::COPY_ACTION
  end

  def move?
    action == Transfer::MOVE_ACTION
  end

  def complete!
    self.exit_status = errors.any? ? 1 : 0
    self.completed_at = Time.now.to_i
  end

  def success?
    exit_status.nil? ? false : exit_status.zero?
  end
end
