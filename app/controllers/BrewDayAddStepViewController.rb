class BrewDayAddStepViewController < UIViewController
  
  extend IB

  attr_accessor :delegate

  # Outlets
  outlet :name, UITextField
  outlet :description, UITextField

  def viewDidLoad
    super
  end

  def viewWillAppear(animated)
    super
  end


  ############################################################################
  # Actions

  def cancelTouched(sender)
    self.dismissModalViewControllerAnimated(true)
  end

  def doneTouched(sender)
    brew_step = BrewStep.new
    brew_step.name = name.text
    brew_step.description = description.text
    delegate.addStepDone(brew_step)    
    self.dismissModalViewControllerAnimated(true)
  end

end