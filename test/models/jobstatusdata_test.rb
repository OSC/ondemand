require 'test_helper'

class JobstatussataTest < ActiveModel::TestCase

  @clusters = OODClusters
  @test_count = 0

  test "test OODClusters is enumerable" do
    clusters = OODClusters
    assert clusters.is_a?(Enumerable), "#{clusters.class.name} is not enumerable"
  end

  test "test PBSPro adapter queued job" do
    native = {
        :job_id=>"3452345.testjob",
        :Job_Name=>"be_5",
        :Job_Owner=>"name@some.cluster",
        :job_state=>"Q",
        :queue=>"testqueue",
        :server=>"h001.test.cluster",
        :Checkpoint=>"u",
        :ctime=>"Fri Jun 23 06:31:33 2017",
        :Error_Path=>"login1.test.cluster:/home/user/bob/cluster/load/run.e718894",
        :group_list=>"testgroup",
        :Hold_Types=>"n",
        :Join_Path=>"n",
        :Keep_Files=>"n",
        :Mail_Points=>"a",
        :mtime=>"Fri Jun 23 06:31:33 2017",
        :Output_Path=>"login1.test.cluster:/home/user/bob/cluster/load/run.o718894",
        :Priority=>"0",
        :qtime=>"Fri Jun 23 06:31:33 2017",
        :Rerunable=>"True",
        :Resource_List=>{
            :cput=>"3600:00:00",
            :mem=>"80gb",
            :mpiprocs=>"14",
            :ncpus=>"14",
            :nodect=>"1",
            :place=>"free",
            :pvmem=>"80gb",
            :select=>"1:ncpus=14:mem=80gb:pcmem=6gb:nodetype=standard:mpiprocs=14",
            :walltime=>"240:00:00"
        },
        :substate=>"10",
        :Variable_List=>"PBS_O_SYSTEM=Linux,PBS_O_SHELL=/bin/bash,PBS_O_HOME=/home/user/bob,PBS_O_LOGNAME=bob,PBS_O_WORKDIR=/home/u30/trzask/ocelote/be_s/5,PBS_O_HOST=login1.test.cluster",
        :comment=>"Not Running: Insufficient amount of resource qlist",
        :etime=>"Fri Jun 23 06:31:33 2017",
        :Submit_arguments=>"run28",
        :project=>"_pbs_project_default"
    }

    info = OodCore::Job::Info.new(
        :id=>native[:job_id],
        :status=>:running,
        :allocated_nodes=>[
            {:name=>"i15n12", :procs=>28},
            {:name=>"i15n13", :procs=>28}
        ],
        :submit_host=>native[:server],
        :job_name=>native[:Job_Name],
        :job_owner=>"name",
        :accounting_id=>nil,
        :procs=>56,
        :queue_name=>"oc_high_pri",
        :wallclock_time=>205742,
        :wallclock_limit=>691200,
        :cpu_time=>5,
        :submission_time=>Time.parse("Tue Jun 20 21:23:59 2017"),
        :dispatch_time=>Time.parse("Tue Jun 20 21:24:47 2017"),
        :native=>native

    )

    cluster = OODClusters.first
    cluster.job_config[:adapter] = 'pbspro'

    jobdata = Jobstatusdata.new(info, cluster, true)

    assert_equal "3452345.testjob", jobdata.pbsid
    assert_equal "be_5", jobdata.jobname
    assert_equal "", jobdata.account
    assert_equal "<div style='white-space: nowrap;'><span class='label label-primary'>Running</span></div>", jobdata.status
    assert_equal ["i15n12", "i15n13"], jobdata.nodes
    assert_equal 1498008287, jobdata.starttime

    jobdata.native_attribs.each do |attrib|
      assert attrib.value.is_a?(String), "#{attrib.name} was #{attrib.value.class.name} expecting String"
    end
    #assert_equal "", jobdata.native_attribs



  end

  @clusters.each do |cluster|

    jobs = cluster.job_adapter.info_all


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

        assert data.status.is_a?(String), data.status.class.name
      end

      test "test cluster #{@test_count}" do
        assert data.cluster.is_a?(String), data.cluster
      end

      test "test nodes #{@test_count}" do
        if job.status.state == :running || job.status.state == :completed
          assert data.nodes.respond_to?('each'), data.nodes.inspect
        else
          assert data.nodes.nil?, "Not nil #{data.nodes.inspect}"
        end
      end

      test "test native_attribs #{@test_count}" do
        assert data.native_attribs.respond_to?('each'), data.native_attribs.inspect
      end

      test "test starttime #{@test_count}" do
        if job.status.state == :running || job.status.state == :completed
          assert data.starttime.is_a?(Integer), data.starttime.inspect

          assert data.starttime >= 0
        else
          assert data.starttime.nil?, "Not nil #{data.starttime}"
        end
      end

      test "test submit_args #{@test_count}" do
        # submit_args is now optional
        if data.submit_args
          assert data.submit_args.is_a?(String), data.submit_args
        end
      end

      test "test output_path #{@test_count}" do
        assert data.output_path.is_a?(String), data.output_path
      end

      test "test extended_available #{@test_count}" do
        assert data.extended_available.in?( [true, false] ), data.extended_available
      end

      test "test shell_url #{@test_count}" do
        assert data.shell_url.is_a?(String), "Was #{data.shell_url.class.name} expecting String"
      end

      test "test file_explorer_url #{@test_count}" do
        assert data.file_explorer_url.is_a?(String), "Was #{data.file_explorer_url.class.name} expecting String"
      end

      @test_count += 1
    end


  end

end


