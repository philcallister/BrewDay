class BrewDayAddNoteViewController < UIViewController
  
  extend IB

  attr_accessor :delegate, :step

  # Outlets
  outlet :note, UITextView
  outlet :step_complete, UISwitch

  def viewDidLoad
    super

    self.step_complete.on = self.step.finished == Bool::YES
    self.note.text = self.step.note
    #self.note.layer.cornerRadius = 7

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
    step.finished = (self.step_complete.isOn) ? Bool::YES : Bool::NO
    self.step.note = self.note.text
    self.step.save!
    delegate.noteComplete(step)
    self.dismissModalViewControllerAnimated(true)
  end

end