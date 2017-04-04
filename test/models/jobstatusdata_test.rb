require 'test_helper'

class JobstatussataTest < ActiveModel::TestCase


  @clusters = OODClusters
  @test_count = 0

  @clusters.each do |cluster|

    jobs = cluster.job_adapter.info



    jobs.each do |job|
      data = Jobstatusdata.new(job, cluster, true)

      test "test job id #{@test_count}" do
        assert data.pbsid.is_a?(String), data.pbsid

        assert data.pbsid.length > 0
      end

      test "test jobname #{@test_count}" do
        assert data.jobname.is_a?(String), data.jobname
      end

      test "test username #{@test_count}" do
        assert data.username.is_a?(String), data.username

        assert data.pbsid.length > 0
      end

      test "test account #{@test_count}" do
        assert data.account.is_a?(String), data.account
      end

      test "test status #{@test_count}" do
        assert_not_nil data.status

        assert data.status.is_a?(Symbol), data.status.class.name
      end

      test "test cluster #{@test_count}" do
        assert data.cluster.instance_of?(OodCore::Cluster), data.cluster
      end

      test "test nodes #{@test_count}" do
        if data.status == :running || data.status == :completed
          assert data.nodes.respond_to?('each'), data.nodes
        else
          assert data.nodes.nil?
        end
      end

      test "test starttime #{@test_count}" do
        if data.status == :running || data.status == :completed
          assert data.starttime.is_a?(Integer), data.starttime

          assert data.starttime >= 0
        else
          assert data.nodes.nil?
        end
      end

      test "test walltime #{@test_count}" do
        assert data.walltime.is_a?(String), data.walltime
      end

      test "test walltime_used #{@test_count}" do
        assert data.walltime_used.is_a?(String), data.walltime_used

        if data.walltime_used != ""
          assert_match(/\d+:\d+:\d+/, data.walltime_used)
        end
      end

      test "test submit_args #{@test_count}" do
        assert data.submit_args.is_a?(String), data.submit_args
      end

      test "test output_path #{@test_count}" do
        assert data.output_path.is_a?(String), data.output_path
      end

      test "test extended_available #{@test_count}" do
        assert_equal true, data.extended_available, "This is not a supported system"
      end

      test "test nodect #{@test_count}" do
        assert data.nodect.is_a?(Integer), data.nodect

        assert data.nodect > 0
      end

      test "test ppn #{@test_count}" do
        assert data.ppn.is_a?(String), data.ppn
      end

      test "test total_cpu #{@test_count}" do
        assert data.total_cpu.is_a?(Integer), data.total_cpu
      end

      test "test queue #{@test_count}" do
        assert data.queue.is_a?(String), data.queue
      end

      test "test cput #{@test_count}" do
        assert data.cput.is_a?(String), data.cput
      end

      test "test mem #{@test_count}" do
        assert data.mem.is_a?(String), data.mem
      end

      test "test vmem #{@test_count}" do
        assert data.vmem.is_a?(String), data.vmem
      end

      test "test terminal_path #{@test_count}" do
        assert data.terminal_path.is_a?(String), "Was #{data.terminal_path.class.name} expecting String"
      end

      test "test fs_path #{@test_count}" do
        assert data.fs_path.is_a?(String), "Was #{data.fs_path.class.name} expecting String"
      end

      @test_count += 1
    end


  end

end


