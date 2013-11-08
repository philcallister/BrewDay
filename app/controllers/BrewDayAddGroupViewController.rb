class BrewDayAddGroupViewController < UIViewController
  
  extend IB

  attr_accessor :delegate

  # Outlets
  outlet :name, UITextField

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
    brew_group = BrewGroup.new
    brew_group.name = name.text
    delegate.addGroupDone(brew_group)    
    self.dismissModalViewControllerAnimated(true)
  end

end