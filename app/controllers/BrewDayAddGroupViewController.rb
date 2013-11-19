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
    brew_group = GroupTemplate.new(name: self.name.text,
                                   position: self.delegate.stepPosition)
    ctx = App.delegate.managedObjectContext
    ctx.insertObject(brew_group)
    brew_group.brew = self.delegate.brew
    brew_group.save!
    self.delegate.addGroupDone(brew_group)
    self.dismissModalViewControllerAnimated(true)
  end


end