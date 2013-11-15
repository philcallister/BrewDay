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
    brew_step = BrewStep.new
    brew_step.name = name.text
    brew_step.info = info.text
    delegate.addStepDone(brew_step)    
    self.dismissModalViewControllerAnimated(true)
  end

  def stepTypeChanged(sender)
    timer_picker.hidden = (sender.selectedSegmentIndex == 0)
  end

end