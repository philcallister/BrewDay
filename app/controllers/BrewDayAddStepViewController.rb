class BrewDayAddStepViewController < UIViewController
  
  extend IB

  attr_accessor :delegate

  # Outlets
  outlet :name, UITextField
  outlet :info, UITextField
  outlet :step_type, UISegmentedControl
  outlet :timer_picker, UIPickerView

  def viewDidLoad
    super
  end

  def viewWillAppear(animated)
    super

    timer_picker.hidden = (step_type.selectedSegmentIndex == 0)
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
    brew_step = StepTemplate.new(name: self.name.text, 
                                 info: self.info.text,
                                 hours: self.timer_picker.selectedRowInComponent(0),
                                 minutes: self.timer_picker.selectedRowInComponent(1),
                                 position: self.delegate.stepPosition)
    ctx = App.delegate.managedObjectContext
    ctx.insertObject(brew_step)
    brew_step.brew = self.delegate.brew
    brew_step.save!
    self.delegate.addStepDone(brew_step)
    self.dismissModalViewControllerAnimated(true)
  end

  def stepTypeChanged(sender)
    timer_picker.hidden = (sender.selectedSegmentIndex == 0)
  end

end