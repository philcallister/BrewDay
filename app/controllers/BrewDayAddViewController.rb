class BrewDayAddViewController < UIViewController
  
  extend IB

  attr_accessor :delegate

  # Outlets
  outlet :name, UITextField
  outlet :info, UITextField
  outlet :style_picker, UIPickerView

  BREW_STYLE = ['ONE', 'TWO', 'THREE', 'FOUR', 'FIVE', 'SIX', 'SEVEN', 'EIGHT', 'NINE', 'TEN']

  def viewDidLoad
    super
  end

  def viewWillAppear(animated)
    super
  end


  ############################################################################
  # Picker View delegation

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


  ############################################################################
  # Actions

  def cancelTouched(sender)
    self.dismissModalViewControllerAnimated(true)
  end

  def doneTouched(sender)
    brew = BrewTemplate.create!(name: name.text, 
                                info: info.text,
                                brew_style: style_picker.selectedRowInComponent(0),
                                position: self.delegate.brewPosition)
    brew.save!
    self.delegate.addDone(brew)    
    self.dismissModalViewControllerAnimated(true)
  end

end