module ItemTemplate

  def is_event?(hours, minutes)
    hours == 0 and minutes == 0
  end

  def is_timer?(hours, minutes)
    !is_event?(hours, minutes)
  end

end