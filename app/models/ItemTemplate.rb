class ItemTemplate < MotionDataWrapper::Model
  # name
  # hours
  # minutes
  # position

  def is_event?
    hours == 0 and minutes == 0
  end

  def is_timer?
    hours != 0 or minutes != 0
  end
  
end