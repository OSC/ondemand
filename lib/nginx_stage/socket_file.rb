module NginxStage
  # A class describing a Unix domain socket
  class SocketFile
    # Path to Unix domain socket file
    # @return [String] path to unix domain socket file
    attr_reader :socket

    # @param socket [String] path to unix domain socket file
    # @raise [MissingSocketFile] if socket file doesn't exist in file system
    # @raise [InvalidSocketFile] if supplied file isn't a valid socket file
    def initialize(socket)
      @socket = socket
      raise MissingSocketFile, "missing socket file: #{socket}" unless File.exist?(socket)
      raise InvalidSocketFile, "invalid socket file: #{socket}" unless File.socket?(socket)
      @processes = get_processes
    end

    # The number of active sessions connected to this socket
    # @return [Fixnum] number of active connections
    def sessions
      # generate array of inodes
      ary_inodes = @processes.map{|h| h[:inode]}.reduce([], :+)

      # count number of inodes without partner (assuming these are connected to
      # apache proxy instead of root nginx process)
      ary_inodes.group_by{|e| e}.select{|k,v| v.size == 1}.map(&:first).count
    end

    # Convert object to string
    # @return [String] path to socket file
    def to_s
      socket
    end

    private
      def get_processes
        str = `lsof -F piu #{socket}`
        ary = []
        str.split(/\n/).each do |l|
          if /^p(?<pid>\d+)$/ =~ l
            ary << {pid: pid, uid: nil, inode: []}
          elsif /^u(?<uid>\d+)$/ =~ l
            ary.last[:uid] = uid
          elsif /^i(?<inode>\d+)$/ =~ l
            ary.last[:inode] << inode
          end
        end
        ary
      end
  end
end
