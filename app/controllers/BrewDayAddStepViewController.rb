class BrewDayAddStepViewController < UIViewController
  
  extend IB

  attr_accessor :delegate, :step_edit, :group

  # Outlets
  outlet :name, UITextField
  outlet :info, UITextField
  outlet :step_type, UISegmentedControl
  outlet :timer_picker, UIPickerView
  outlet :nav_item, UINavigationItem

  def viewDidLoad
    super
  end

  def viewWillAppear(animated)

    super
    if self.step_edit
      self.nav_item.title = 'Edit Step'
      self.name.text = self.step_edit.name
      self.info.text = self.step_edit.info
      self.step_type.selectedSegmentIndex = self.step_edit.step_type
      self.timer_picker.selectRow(self.step_edit.minutes, inComponent: 0, animated: true)
    else
      self.nav_item.title = 'Add Step'
    end

    # For the step type, we'll need to determine if the group has a
    # timer set.  If it doesn't, we won't have a alarm item
    if self.group && self.group.is_event?
      self.step_type.removeSegmentAtIndex(2, animated:false)
    end

    self.timer_picker.hidden = (self.step_type.selectedSegmentIndex == StepTemplate::STEP_TYPE_EVENT)
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
    if self.step_edit
      self.step_edit.name = self.name.text
      self.step_edit.info = self.info.text
      self.step_edit.step_type = self.step_type.selectedSegmentIndex
      self.step_edit.minutes = (self.step_type.selectedSegmentIndex == StepTemplate::STEP_TYPE_EVENT) ? 0 : self.timer_picker.selectedRowInComponent(0) + 1
      self.step_edit.save!
      self.delegate.editStepDone(self.step_edit)
    else
      brew_step = StepTemplate.new(name: self.name.text, 
                                   info: self.info.text,
                                   step_type: self.step_type.selectedSegmentIndex,
                                   minutes: (self.step_type.selectedSegmentIndex == StepTemplate::STEP_TYPE_EVENT) ? 0 : self.timer_picker.selectedRowInComponent(0) + 1,
                                   position: self.group.steps.count)
      ctx = App.delegate.managedObjectContext
      ctx.insertObject(brew_step)
      brew_step.group = self.group
      brew_step.save!
      self.delegate.addStepDone(brew_step, self.group)
    end
    self.dismissModalViewControllerAnimated(true)
  end

  def stepTypeChanged(sender)
    self.timer_picker.hidden = (sender.selectedSegmentIndex == StepTemplate::STEP_TYPE_EVENT)
  end

end