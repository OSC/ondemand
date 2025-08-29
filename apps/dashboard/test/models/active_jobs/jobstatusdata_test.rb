# frozen_string_literal: true

require 'test_helper'
require Rails.application.root.join('test','models','active_jobs','active_jobs_test_helper.rb')

module ActiveJobs
  class JobstatusdataTest < ActiveSupport::TestCase
    include ActiveJobsTestHelper

    # Dummy class for OodCore::Clusters
    class FakeClusters
      include Enumerable

      def initialize(clusters)
        @clusters = clusters
      end

      def [](id)
        @clusters.detect { |cluster| cluster == id }
      end

      def each(&block)
        @clusters.each(&block)
      end
    end
    
    # def clusters
    #   OodCore::Clusters.load_file('test/fixtures/config/clusters.d')
    # end
  
    def setup
      OODClusters.stubs(:[]).with('owens').returns(FakeCluster.new(id: :owens, title: 'Owens'))
      OODClusters.stubs(:[]).with('oakley').returns(FakeCluster.new(id: :oakley, title: 'Oakley Cluster'))
      OODClusters.stubs(:[]).with(nil).returns(nil)
      OODClusters.stubs(:[]).with('').returns(nil)
      OODClusters.stubs(:first).returns(OODClusters['owens'])
    end

    test 'default no extensions' do 
      info = OodCore::Job::Info.new(
        id:             12,
        job_name:       'test_job',
        job_owner:      'Fake User',
        accounting_id:  123,
        status:         :running,
        wallclock_time: 120,
        queue_name:     'regular'
      )
      
      data = Jobstatusdata.new(info)
      
      # Test supplied data
      assert_equal '12',          data.pbsid
      assert_equal 'test_job',  data.jobname
      assert_equal 'Fake User', data.username
      assert_equal '123',         data.account
      assert_equal 'running',   data.status
      assert_equal '00:02:00',  data.walltime_used
      assert_equal 'regular',   data.queue

      # Test defaults
      assert data.extended_available
      assert_equal OODClusters.first.id.to_s, data.cluster
      # The title option can be set in metadata, so we make sure to grab that if set.
      exp = OODClusters.first.metadata.title || OODClusters.first.id.to_s.titleize
      assert_equal exp, data.cluster_title
    end

    test 'default with cluster supplied' do 
      info = OodCore::Job::Info.new(
        id:             12,
        job_name:       'test_job',
        job_owner:      'Fake User',
        accounting_id:  123,
        status:         :running,
        wallclock_time: 120,
        queue_name:     'regular'
      )

      data = Jobstatusdata.new(info, 'oakley')
      
      # Test supplied data
      assert_equal '12',          data.pbsid
      assert_equal 'test_job',  data.jobname
      assert_equal 'Fake User', data.username
      assert_equal '123',         data.account
      assert_equal 'running',   data.status
      assert_equal '00:02:00',  data.walltime_used
      assert_equal 'regular',   data.queue

      # Test defaults
      assert data.extended_available

      # Test cluster data
      assert_equal 'oakley', data.cluster
      assert_equal 'Oakley Cluster', data.cluster_title
    end

    # To test native extensions, we define a plausible native class for each scheduler
    class DummyNative
      def initialize(data)
        @data = data
      end
      
      def fetch(key, default = nil)
        @data.fetch(key, default)
      end
    
      def [](key)
        @data[key]
      end
    end

    # Special setup method to keep extension tests consistent
    def extensions_test_setup(adapter, native_data)
      # Set scheduler on cluster
      OODClusters['oakley'].set_adapter(adapter)

      # Define native
      native = DummyNative.new(native_data)

      # Create job
      samplejob = OodCore::Job::Info.new(
        id: "123450",
        status: :queued,
        allocated_nodes: [NodeInfo.new(name: 'node001')],
        submit_host: "submit01.cluster",
        job_name: "TestJob1",
        job_owner: "user1",
        accounting_id: "acct123",
        procs: 4,
        queue_name: "batch",
        wallclock_time: 3600,
        wallclock_limit: 7200,
        cpu_time: 1800,
        submission_time: Time.now.to_i - 3600,
        dispatch_time: Time.now.to_i - 1800,
        gpus: 1,
        native: native,
        tasks: [{ id: "12345.1", status: :running }]
      )
      
      # Run test
      data = Jobstatusdata.new(samplejob, 'oakley', true)
    end  

    # Helper method to access native_attribs
    def get_native_value(data, name)
      data.native_attribs.find { |a| a.name == name }.value
    end

    # To consistently check attributes unaffected by extensions
    def assert_shared_attributes(data)
      assert_equal 'Oakley Cluster', data.cluster_title
      assert_equal '123450',         data.pbsid
      assert_equal 'TestJob1',       data.jobname
      assert_equal 'user1',          data.username
      assert_equal 'acct123',        data.account
      assert_equal 'batch',          data.queue
      assert_equal '01:00:00',       data.walltime_used
    end

    test 'use torque extensions' do
      # Set up native
      torque_data = {
        Resource_List: {
          walltime: "02:00:00",
          nodect: 4,
          nodes: "node01+node02+node03+node04:ppn=8"
        },
        resources_used: {
          cput: "01:30:00",
          mem: "4gb",
          vmem: "6gb"
        },
        comment: "Test job",
        submit_args: "--test-args",
        Output_Path: "server:/home/user/output.log"
      }

      # Execute test
      data = extensions_test_setup('torque', torque_data)

      # Check basic attributes
      assert_shared_attributes(data)
      
      # Check extended attributes
      assert_equal '02:00:00',    get_native_value(data, 'Walltime')
      assert_equal 4,             get_native_value(data, 'Node Count')
      assert_equal 'node001',     get_native_value(data, 'Node List')
      assert_equal '8',           get_native_value(data, 'PPN')
      assert_equal 32,            get_native_value(data, 'Total CPUs')
      assert_equal '01:30:00',    get_native_value(data, 'CPU Time')
      assert_equal '4gb',         get_native_value(data, 'Memory')
      assert_equal '6gb',         get_native_value(data, 'Virtual Memory')
      assert_equal 'Test job',    get_native_value(data, 'Comment')
      assert_equal '--test-args', data.submit_args
      assert_equal '/home/user',  Pathname.new(data.output_path).dirname.to_s

      assert_not_nil data.file_explorer_url
      assert_not_nil data.shell_url
    end

    test 'use slurm extensions' do
      slurm_data = {
        array_job_id: "12345",
        array_task_id: "1",
        state: "running",
        reason: "None",
        nodes: 2,
        cpus: 64,
        time_limit: "01:00:00",
        start_time: "2025-08-28T14:00:00",
        end_time: "2025-08-28T15:00:00",
        min_memory: "128GB",
        gres: "gres:gpu:2",
        work_dir: "/home/user/slurm_job"
      }

      # Execute test
      data = extensions_test_setup('slurm', slurm_data)

      # Check basic attributes
      assert_shared_attributes(data)

      # Check extensions
      assert_equal '12345',                get_native_value(data, 'Array Job Id')
      assert_equal '1',                    get_native_value(data, 'Array Task Id')
      assert_equal 'running',              get_native_value(data, 'State')
      assert_equal 'None',                 get_native_value(data, 'Reason')
      assert_equal 2,                      get_native_value(data, 'Total Nodes')
      assert_equal 'node001',              get_native_value(data, 'Node List')
      assert_equal 64,                     get_native_value(data, 'Total CPUs')
      assert_equal '01:00:00',             get_native_value(data, 'Time Limit')
      assert_equal '01:00:00',             get_native_value(data, 'Time Used')
      assert_equal '2025-08-28 14:00:00',  get_native_value(data, 'Start Time')
      assert_equal '2025-08-28 15:00:00',  get_native_value(data, 'End Time')
      assert_equal '128GB',                get_native_value(data, 'Memory')
      assert_equal 'gpu:2',                get_native_value(data, 'GRES')
      assert_equal '/home/user/slurm_job', data.output_path

      assert_not_nil data.file_explorer_url
      assert_not_nil data.shell_url
    end

    test 'use lsf extensions' do
      # Set up native LSF data
      lsf_data = {
        from_host:   'submit01',
        exec_host:   'exec01',
        submit_time: '2025-08-28 11:50:00',
        project:     'test-project',
        cpu_used:    '01:10:30',
        mem:         '2048MB',
        swap:        '4096MB',
        pids:        '12345,12346',
        start_time:  '2025-08-28 12:00:00',
        finish_time: '2025-08-28 13:10:00'
      }
    
      # Execute test
      data = extensions_test_setup('lsf', lsf_data)
    
      # Check basic/shared attributes (same helper used by torque/slurm tests)
      assert_shared_attributes(data)
    
      # Check extended/native attributes specific to LSF
      assert_equal 'submit01',            get_native_value(data, 'From Host')
      assert_equal 'exec01',              get_native_value(data, 'Exec Host')
      assert_equal 'test-project',        get_native_value(data, 'Project Name')
      assert_equal 'node001',             get_native_value(data, 'Node List')
      assert_equal '01:10:30',            get_native_value(data, 'CPU Used')
      assert_equal '2048MB',              get_native_value(data, 'Mem')
      assert_equal '4096MB',              get_native_value(data, 'Swap')
      assert_equal '12345,12346',         get_native_value(data, 'PIDs')
      assert_equal '2025-08-28 11:50:00', get_native_value(data, 'Submit Time')
      assert_equal '2025-08-28 12:00:00', get_native_value(data, 'Start Time')
      assert_equal '2025-08-28 13:10:00', get_native_value(data, 'Finish Time')
    end
    

    test 'use pbspro extensions' do
      # Set up native PBS Pro data
      pbspro_data = {
        Resource_List: {
          walltime: '02:00:00',
          nodect:   4,
          ncpus:    '32',
          select:   '2:ncpus=16:mem=64gb:ngpus=2'
        },
        resources_used: {
          cput: '5400',  # seconds => pretty_time => "01:30:00"
          mem:  '4gb',
          vmem: '6gb'
        },
        group_list:       'groupA,groupB',
        comment:          'PBSPro test job',
        Submit_arguments: '--pbspro-args',
        Output_Path:      'server:/home/user/output.log'
      }
    
      # Execute test
      data = extensions_test_setup('pbspro', pbspro_data)
    
      # Check basic attributes
      assert_shared_attributes(data)
    
      # Check extended/native attributes specific to PBS Pro
      assert_equal '02:00:00',                    get_native_value(data, 'Walltime')
      assert_equal '01:00:00',                    get_native_value(data, 'Walltime Used')
      assert_equal '4',                           get_native_value(data, 'Node Count')
      assert_equal 'node001',                     get_native_value(data, 'Node List')
      assert_equal '32',                          get_native_value(data, 'Total CPUs')
      assert_equal '01:30:00',                    get_native_value(data, 'CPU Time')
      assert_equal '4gb',                         get_native_value(data, 'Memory')
      assert_equal '6gb',                         get_native_value(data, 'Virtual Memory')
      assert_equal '2:ncpus=16:mem=64gb:ngpus=2', get_native_value(data, 'Select')
      assert_equal 'PBSPro test job',             get_native_value(data, 'Comment')
      assert_equal 'groupA,groupB',               get_native_value(data, 'Group List')
    
      assert_equal '--pbspro-args',               data.submit_args
      assert_equal '/home/user',                  Pathname.new(data.output_path).dirname.to_s
    end
    
    test 'use sge extensions' do
      # Set up native SGE data
      sge_data = {
        JB_version:               '8.6.12',
        JB_exec_file:             '/opt/sge/bin/lx-amd64/sge_shepherd',
        JB_script_file:           '/home/user/job.sh',
        JB_script_size:           2048,
        JB_execution_time:        '00:45:00',
        JB_deadline:              '2025-08-28 16:00:00',
        JB_uid:                   1001,
        JB_group:                 'users',
        JB_gid:                   1001,
        JB_account:               'projectA',
        JB_cwd:                   '/home/user/work',
        JB_notify:                'n',
        JB_type:                  'binary',
        JB_reserve:               'y',
        JB_priority:              '0.5',
        JB_jobshare:              0,
        JB_verify:                'false',
        JB_checkpoint_attr:       'cwhen',
        JB_checkpoint_interval:   '00:10:00',
        JB_restart:               'y',
        ST_name:                  '--sge-args',
        PN_path:                  '/home/user/sge_job/output.log'
      }
    
      # Execute test
      data = extensions_test_setup('sge', sge_data)
    
      # Check basic/shared attributes
      assert_shared_attributes(data)
    
      # Check SGE-native mapped attributes
      assert_equal '8.6.12',                             get_native_value(data, 'Job Version')
      assert_equal '/opt/sge/bin/lx-amd64/sge_shepherd', get_native_value(data, 'Job Exec File')
      assert_equal '/home/user/job.sh',                  get_native_value(data, 'Job Script File')
      assert_equal 2048,                                 get_native_value(data, 'Job Script Size')
      assert_equal '00:45:00',                           get_native_value(data, 'Job Execution Time')
      assert_equal '2025-08-28 16:00:00',                get_native_value(data, 'Job Deadline')
      assert_equal 1001,                                 get_native_value(data, 'Job UID')
      assert_equal 'users',                              get_native_value(data, 'Job Group')
      assert_equal 1001,                                 get_native_value(data, 'Job GID')
      assert_equal 'projectA',                           get_native_value(data, 'Job Account')
      assert_equal '/home/user/work',                    get_native_value(data, 'Current Working Directory')
      assert_equal 'n',                                  get_native_value(data, 'Notifications')
      assert_equal 'binary',                             get_native_value(data, 'Job Type')
      assert_equal 'y',                                  get_native_value(data, 'Reserve')
      assert_equal '0.5',                                get_native_value(data, 'Job Priority')
      assert_equal 0,                                    get_native_value(data, 'Job Share')
      assert_equal 'false',                              get_native_value(data, 'Job Verify')
      assert_equal 'cwhen',                              get_native_value(data, 'Job Checkpoint Attr')
      assert_equal '00:10:00',                           get_native_value(data, 'Job Checkpoint Interval')
      assert_equal 'y',                                  get_native_value(data, 'Job Restart')
    end

    test 'use fujitsu tcs extensions' do
      # Set up native Fujitsu TCS data
      fujitsu_data = {
        NODES:      '2',                                      # echoed as-is
        ACCEPT:     '2025-08-28 12:00:00',                    # Submission Time
        START_DATE: '2025-08-28 12:05:00',                    # Start Time
        STD:        '/home/user/fj_job/std.out'               # used to build URLs
      }
    
      # Execute test
      data = extensions_test_setup('fujitsu_tcs', fujitsu_data)
    
      # Check basic/shared attributes
      assert_shared_attributes(data)
    
      # Check extended/native attributes specific to Fujitsu TCS
      assert_equal '2',                         get_native_value(data, 'Nodes')
      assert_equal '02:00:00',                  get_native_value(data, 'Time Limit')
      assert_equal '2025-08-28 12:00:00',       get_native_value(data, 'Submission Time')
      assert_equal '2025-08-28 12:05:00',       get_native_value(data, 'Start Time')
    
      # It does build file_explorer_url and shell_url from dirname(STD); ensure they were set
      assert_not_nil data.file_explorer_url
      assert_not_nil data.shell_url
    end
    
  end
end
