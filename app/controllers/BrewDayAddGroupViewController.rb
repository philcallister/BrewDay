class BrewDayAddGroupViewController < UIViewController
  
  extend IB

  attr_accessor :delegate, :group_edit, :steps_edit

  # Outlets
  outlet :name, UITextField
  outlet :group_type, UISegmentedControl
  outlet :timer_picker, UIPickerView
  outlet :nav_item, UINavigationItem

  EVENT = 0
  TIMER = 1

  def viewDidLoad
    super
  end

  def viewWillAppear(animated)
    super
    if self.group_edit
      self.nav_item.title = 'Edit Group'
      self.name.text = self.group_edit.name
      self.group_type.selectedSegmentIndex = (self.group_edit.minutes == 0) ? EVENT : TIMER
      self.timer_picker.selectRow(self.group_edit.minutes, inComponent: 0, animated: true)
    else
      self.nav_item.title = 'Add Group'
    end
    self.timer_picker.hidden = (self.group_type.selectedSegmentIndex == EVENT)
  end


  ############################################################################
  # Picker View delegation

  def numberOfComponentsInPickerView(pickerView)
    1    
  end

  def pickerView(pickerView, titleForRow:row, forComponent:component)
    (row + 1).to_s
  end

  def pickerView(pickerView, numberOfRowsInComponent:component)
    180
  end

  def pickerView(pickerView, didSelectRow:row, inComponent:component)
  end


  ############################################################################
  # Actions

  def cancelTouched(sender)
    self.dismissModalViewControllerAnimated(true)
  end

  def doneTouched(sender)
    if self.group_edit
      self.group_edit.name = self.name.text
      self.group_edit.minutes = (self.group_type.selectedSegmentIndex == EVENT) ? 0 : self.timer_picker.selectedRowInComponent(0) + 1
      # For the existing brew steps, change any "alarm" to "event" if the group
      # has also changed to an event
      if self.group_edit.is_event?
        self.steps_edit.each do |step|
          if step.step_type == StepTemplate::STEP_TYPE_ALARM
            step.step_type = StepTemplate::STEP_TYPE_EVENT
            step.minutes = 0
            step.save!
          end
        end
      end
      self.group_edit.save!
      self.delegate.editGroupDone(self.group_edit)
    else
      brew_group = GrpTemplate.new(name: self.name.text,
                                   minutes: (self.group_type.selectedSegmentIndex == EVENT) ? 0 : self.timer_picker.selectedRowInComponent(0) + 1,
                                   position: self.delegate.groupPosition)
      ctx = App.delegate.managedObjectContext
      ctx.insertObject(brew_group)
      brew_group.brew = self.delegate.brew
      brew_group.save!
      self.delegate.addGroupDone(brew_group)
    end
    self.dismissModalViewControllerAnimated(true)
  end

  def groupTypeChanged(sender)
    self.timer_picker.hidden = (sender.selectedSegmentIndex == EVENT)
  end


end