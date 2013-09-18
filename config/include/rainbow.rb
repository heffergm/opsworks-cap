## our colourful custom loggers
class Capistrano::Logger
  def notice(msg)
    self.info msg, "NOTICE".foreground(:blue)
  end
  def attention(msg)
    self.important msg, "ATTENTION".foreground(:yellow)
  end
  def aborting(msg)
    self.important msg, "ABORTING".foreground(:red)
  end
  def achtung(msg)
    self.important msg, "ACHTUNG!".foreground(:red)
  end
  def runtime(msg)
    self.important msg, "RUNTIME OPTIONS".foreground(:green)
  end
end

