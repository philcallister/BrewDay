class BrewDayAddStepViewController < UIViewController
  
  extend IB

  attr_accessor :delegate, :step_edit

  # Outlets
  outlet :name, UITextField
  outlet :info, UITextField
  outlet :step_type, UISegmentedControl
  outlet :timer_picker, UIPickerView
  outlet :nav_item, UINavigationItem

  EVENT = 0
  TIMER = 1

  def viewDidLoad
    super
    if self.step_edit
      self.nav_item.title = 'Edit Step'
      self.name.text = step_edit.name
      self.info.text = step_edit.info
      self.step_type.selectedSegmentIndex = (step_edit.hours == 0 and step_edit.minutes == 0) ? EVENT : TIMER
      self.timer_picker.selectRow(step_edit.hours, inComponent: 0, animated: true)
      self.timer_picker.selectRow(step_edit.minutes, inComponent: 1, animated: true)
    else
      self.nav_item.title = 'Add Step'
    end
  end

  def viewWillAppear(animated)
    super

    timer_picker.hidden = (step_type.selectedSegmentIndex == EVENT)
  end


  ############################################################################
  # Picker View delegation

  def numberOfComponentsInPickerView(pickerView)
    2    
  end

  def pickerView(pickerView, titleForRow:row, forComponent:component)
    row.to_s
  end

  def pickerView(pickerView, numberOfRowsInComponent:component)
    (component == 0) ? 25 : 60
  end

  def pickerView(pickerView, didSelectRow:row, inComponent:component)
    puts ">>>>> Selected: #{component} | #{row}"
  end


  ############################################################################
  # Actions

  def cancelTouched(sender)
    self.dismissModalViewControllerAnimated(true)
  end

  def doneTouched(sender)
    if step_edit
      self.step_edit.name = self.name.text
      self.step_edit.info = self.info.text
      self.step_edit.hours = (step_type.selectedSegmentIndex == EVENT) ? 0 : self.timer_picker.selectedRowInComponent(0)
      self.step_edit.minutes = (step_type.selectedSegmentIndex == EVENT) ? 0 : self.timer_picker.selectedRowInComponent(1)
      self.step_edit.save!
      self.delegate.editStepDone(self.step_edit)
    else
      brew_step = StepTemplate.new(name: self.name.text, 
                                   info: self.info.text,
                                   hours: (step_type.selectedSegmentIndex == EVENT) ? 0 : self.timer_picker.selectedRowInComponent(0),
                                   minutes: (step_type.selectedSegmentIndex == EVENT) ? 0 : self.timer_picker.selectedRowInComponent(1),
                                   position: self.delegate.stepPosition)
      ctx = App.delegate.managedObjectContext
      ctx.insertObject(brew_step)
      brew_step.brew = self.delegate.brew
      brew_step.save!
      self.delegate.addStepDone(brew_step)
    end
    self.dismissModalViewControllerAnimated(true)
  end

  def stepTypeChanged(sender)
    timer_picker.hidden = (sender.selectedSegmentIndex == EVENT)
  end

end