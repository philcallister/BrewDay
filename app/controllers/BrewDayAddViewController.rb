class BrewDayAddViewController < UIViewController
  
  extend IB

  attr_accessor :delegate

  # Outlets
  outlet :name, UITextField
  outlet :description, UITextField
  outlet :style_picker, UIPickerView

  BREW_STYLE = ['ONE', 'TWO', 'THREE', 'FOUR', 'FIVE', 'SIX', 'SEVEN', 'EIGHT', 'NINE', 'TEN']

  def viewDidLoad
    super
  end

  def viewWillAppear(animated)
    super
  end

  def numberOfComponentsInPickerView(pickerView)
    1    
  end

  def pickerView(pickerView, numberOfRowsInComponent:component)
    BREW_STYLE.length
  end

  def pickerView(pickerView, didSelectRow:row, inComponent:component)
    puts ">>>>> Selected Style: #{BREW_STYLE[row]}"
  end

  def pickerView(pickerView, titleForRow:row, forComponent:component)
    BREW_STYLE[row]
  end

  def cancelTouched(sender)
    self.dismissModalViewControllerAnimated(true)
  end

  def doneTouched(sender)
    brew_day = BrewDay.new
    brew_day.name = name.text
    brew_day.description = description.text
    brew_day.BREW_STYLE = BREW_TYPE[type_picker.selectedRowInComponent(0)]
    delegate.addDone(brew_day)    
    self.dismissModalViewControllerAnimated(true)
  end

end