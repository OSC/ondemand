
module JobLogger

  def upsert_job!(directory, job)
    existing_jobs = jobs(directory)
    stored_job = existing_jobs.detect { |j| j.id == job.id && j.cluster == job.cluster }

    if stored_job.nil?
      new_jobs = (existing_jobs + [job.to_h]).map(&:to_h)
    else
      new_jobs = existing_jobs.map(&:to_h)
      idx = existing_jobs.index(stored_job)
      new_jobs[idx].merge!(job.to_h) { |_key, old_val, new_val| new_val.nil? ? old_val : new_val }
    end

    JobLoggerHelper.write_log(directory, new_jobs)
  end

  def delete_job!(directory, job)
    existing_jobs = jobs(directory)
    stored_job = existing_jobs.detect { |j| j.id == job.id && j.cluster == job.cluster }

    return if stored_job.nil?

    new_jobs = existing_jobs.map(&:to_h)
    idx = existing_jobs.index(stored_job)
    new_jobs.delete_at(idx)

    JobLoggerHelper.write_log(directory, new_jobs)
  end

  # def write_job_log!(directory, jobs)
  #   JobLoggerHelper.write_log!(directory, jobs)
  # endd

  def jobs(directory)
    file = JobLoggerHelper.log_file(directory)
    begin
      data = YAML.safe_load(File.read(file.to_s), permitted_classes: [Time]).to_a
      data.map { |job_data| HpcJob.new(**job_data) }
    rescue StandardError => e
      Rails.logger.error("Cannot read job log file '#{file}' due to error: #{e}")
      []
    end
  end

  # helper methods here are located here so that they don't
  # bleed into the class that uses this module
  class JobLoggerHelper
    class << self
      def log_file(directory)
        Pathname.new("#{directory}/.ondemand/job_log.yml").tap do |path|
          FileUtils.touch(path.to_s) unless path.exist?
        end
      end

      def write_log(directory, jobs)
        file = log_file(directory)
        File.write(file.to_s, jobs.to_yaml)
      end
    end
  end
end
