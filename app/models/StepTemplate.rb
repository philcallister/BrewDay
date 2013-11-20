class StepTemplate < ItemTemplate
  # info
  # hours
  # minutes

  def is_event?
    hours == 0 and minutes == 0
  end

end