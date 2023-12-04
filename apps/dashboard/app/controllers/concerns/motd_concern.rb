module MotdConcern
  def set_motd
      @motd = MotdFile.new.formatter 
  end
end