class StepTemplate < MotionDataWrapper::Model
  
  # name
  # info
  # step_type
  # minutes
  # position
  # group => to one

  STEP_TYPE_EVENT = 0
  STEP_TYPE_TIMER = 1
  STEP_TYPE_ALARM = 2

  def step_text
    case step_type
    when STEP_TYPE_TIMER
      "#{self.minutes}"
    when STEP_TYPE_ALARM
      "@#{self.minutes}"
    end
  end

end