class BrewDayAddViewController < UIViewController
  
  extend IB

  attr_accessor :delegate
  attr_accessor :brew_edit

  # Outlets
  outlet :name, UITextField
  outlet :info, UITextField
  outlet :style_picker, UIPickerView
  outlet :nav_item, UINavigationItem

  BREW_STYLE = ['ONE', 'TWO', 'THREE', 'FOUR', 'FIVE', 'SIX', 'SEVEN', 'EIGHT', 'NINE', 'TEN']

  def viewDidLoad
    super
  end

  def viewWillAppear(animated)
    super
    if self.brew_edit
      self.nav_item.title = 'Edit Brew Day'
      self.name.text = brew_edit.name
      self.info.text = brew_edit.info
      self.style_picker.selectRow(brew_edit.brew_style, inComponent: 0, animated: true)
    else
      self.nav_item.title = 'Add Brew Day'
    end
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

    if self.brew_edit
      self.brew_edit.name = self.name.text
      self.brew_edit.info = self.info.text
      self.brew_edit.brew_style = self.style_picker.selectedRowInComponent(0)
      self.brew_edit.save!
      self.delegate.editBrewDone(self.brew_edit)
    else
      brew = BrewTemplate.create!(name: self.name.text, 
                                  info: self.info.text,
                                  brew_style: self.style_picker.selectedRowInComponent(0),
                                  position: self.delegate.brewPosition)
      brew.save!
      self.delegate.addBrewDone(brew)
    end
    self.dismissModalViewControllerAnimated(true)
  end

end