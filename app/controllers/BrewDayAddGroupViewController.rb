class BrewDayAddGroupViewController < UIViewController
  
  extend IB

  attr_accessor :delegate
  attr_accessor :group_edit

  # Outlets
  outlet :name, UITextField
  outlet :nav_item, UINavigationItem


  def viewDidLoad
    super
  end

  def viewWillAppear(animated)
    super
    if self.group_edit
      self.nav_item.title = 'Edit Group'
      self.name.text = group_edit.name
    else
      self.nav_item.title = 'Add Group'
    end
  end


  ############################################################################
  # Actions

  def cancelTouched(sender)
    self.dismissModalViewControllerAnimated(true)
  end

  def doneTouched(sender)
    if group_edit
      self.group_edit.name = self.name.text
      self.group_edit.save!
      self.delegate.editGroupDone(self.group_edit)
    else
      brew_group = GroupTemplate.new(name: self.name.text,
                                     position: self.delegate.stepPosition)
      ctx = App.delegate.managedObjectContext
      ctx.insertObject(brew_group)
      brew_group.brew = self.delegate.brew
      brew_group.save!
      self.delegate.addGroupDone(brew_group)
    end
    self.dismissModalViewControllerAnimated(true)
  end


end