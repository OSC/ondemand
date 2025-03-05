Rails.application.config.after_initialize do
  require 'ood_core'
  
  class OodCore::Job::Adapters::Localhost < OodCore::Job::Adapter

    def submit(script, after: [], afterok: [], afternotok: [], afterany: [])
      file = "/tmp/#{SecureRandom.uuid}"
      content = if script.shell_path.nil?
                      script.content
                    else
                      "#!#{script.shell_path}\n#{script.content}"
                    end

      File.open(file, 'w') { |f| f.write(content) }
      FileUtils.chmod(0755, file)
      
      pid = spawn(file, [:out, :err] => [script.output_path, 'w'])
      Process.detach(pid)
      pid
    end

    def info(id)
      pinfo = begin
                Process.getpgid(id.to_i)
              rescue Errno::ESRCH
                nil
              end

      data = { id: id.to_s }
      if pinfo.nil?
        OodCore::Job::Info.new(**data.merge({ status: :completed }))
      else
        OodCore::Job::Info.new(**data.merge({ status: :running }))
      end
    end

    def delete(id)
      pinfo = Process.getpgid(id.to_i)
      Process.kill('TERM', id.to_i)    
    end

    def info_all(attrs: nil)
      []
    end
  end  

  class OodCore::Job::Factory
    def self.build_localhost(config = {})
      OodCore::Job::Adapters::Localhost.new
    end

    def self.build(config)
      c = config.to_h.symbolize_keys

      adapter = c.fetch(:adapter) { raise AdapterNotSpecified, "job configuration does not specify adapter" }.to_s

      path_to_adapter = "ood_core/job/adapters/#{adapter}"
      begin
        require path_to_adapter unless adapter == 'localhost'
      rescue Gem::LoadError => e
        raise Gem::LoadError, "Specified '#{adapter}' for job adapter, but the gem is not loaded."
      rescue LoadError => e
        raise LoadError, "Could not load '#{adapter}'. Make sure that the job adapter in the configuration file is valid."
      end

      adapter_method = "build_#{adapter}"

      unless respond_to?(adapter_method)
        raise AdapterNotFound, "job configuration specifies nonexistent #{adapter} adapter"
      end

      send(adapter_method, c)
    end
  end
end