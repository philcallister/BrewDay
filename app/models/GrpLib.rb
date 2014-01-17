module GrpLib

  def is_event?
    self.minutes == 0
  end

  def is_timer?
    !is_event?
  end

  def group_text
    # is_event? ? nil : "#{format('%02d', self.minutes)}"
    is_event? ? nil : self.minutes.to_s
  end

end
