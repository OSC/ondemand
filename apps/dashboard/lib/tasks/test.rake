namespace :test do
  namespace :jobs do
    WORKDIR = Pathname.new(ENV["WORKDIR"] || "~/test_jobs").expand_path

    directory WORKDIR

    task :all => OodAppkit.clusters.map(&:id)

    OodAppkit.clusters.each do |cluster|
      desc "Test the cluster: #{cluster.id}"
      task cluster.id => [:environment, WORKDIR] do
        unless cluster.job_allow?
          puts "Skipping '#{cluster.id}' as it doesn't allow job submission."
          next
        end
        puts "Testing cluster '#{cluster.id}'..."
        test_string = "TEST A B C"
        output_path = WORKDIR.join("output_#{cluster.id}_#{Time.now.iso8601}.log".parameterize.underscore)
        script = OodCore::Job::Script.new(
          job_name: "test_jobs_#{cluster.id}",
          workdir: WORKDIR,
          output_path: output_path,
          wall_time: 60,
          shell_path: "/bin/bash",
          content: %{echo "#{test_string}"},
          native: Shellwords.split(ENV["SUBMIT_ARGS"] || "")
        )
        puts "Submitting job..."
        adapter = cluster.job_adapter
        job = adapter.submit script
        puts "Got job id '#{job}'"
        loop do
          status = adapter.status(job)
          puts "Job has status of #{status.to_s}"
          break if status.completed?
          sleep 5
        end
        if output_path.exist?
          output = output_path.read
          if /^#{Regexp.escape(test_string)}$/.match(output)
            puts "Test for '#{cluster.id}' PASSED!"
          else
            puts "Couldn't find the test string '#{test_string}' in job output:"
            puts ""
            puts output.gsub(/^/, "    ")
            puts ""
            puts "Test for '#{cluster.id}' FAILED!"
          end
          output_path.rmtree
        else
          puts "Output file from job does not exist: #{output_path}"
          puts "Test for '#{cluster.id}' FAILED!"
        end
        puts "Finished testing cluster '#{cluster.id}'"
      end
    end
  end

  desc "Test all clusters"
  task :jobs => "jobs:all"
end
