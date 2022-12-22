require 'logger'
class Log
    @log_file = 'log/logger.log'
    
    def self.write(message)
        file = Log.open_file
        logger = Logger.new(file)        
        logger.debug(message)
        logger.close
    end

    def self.open_file
        file = File.open(@log_file, File::WRONLY | File::APPEND | File::CREAT)
    end

end