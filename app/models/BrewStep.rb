class BrewStep

  attr_accessor :name, :description

  def finished?
    !@finished.nil?
  end

  def finished
    @finished = Time.now
  end

  def finished_time
    @finished
  end

end