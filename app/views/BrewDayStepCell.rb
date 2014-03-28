class BrewDayStepCell < UITableViewCell

  extend IB

  # Outlets
  outlet :name, UILabel
  outlet :info, UILabel
  outlet :timer, UILabel

  def populate(item)
    self.name.text = item.name
    self.info.text = item.info
    self.timer.text = item.step_text

    bgColorView = UIView.alloc.init
    bgColorView.backgroundColor = UIColor.colorWithRed(182.0/255.0, green:182.0/255.0, blue:182.0/255.0, alpha:1.0)
    self.selectedBackgroundView = bgColorView
    color = UIColor.whiteColor
    self.name.highlightedTextColor = color
    self.info.highlightedTextColor = color
    self.timer.highlightedTextColor = UIColor.whiteColor

    markStep(item)
  end

  def markStep(item)
    if item.is_a? Step
      if item.finished == Bool::YES
        markFinished
      elsif item.marked == Bool::YES
        markMarked
      else
        markDefault
      end
    end
  end

  def markDefault
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    self.tintColor = nil
    self.backgroundColor = UIColor.whiteColor
    self.name.color = UIColor.colorWithRed(12.0/255.0, green:97.0/255.0, blue:146.0/255.0, alpha:1.0)
    self.info.color = UIColor.colorWithRed(184.0/255.0, green:184.0/255.0, blue:184.0/255.0, alpha:1.0)
    self.timer.color = UIColor.colorWithRed(91.0/255.0, green:179.0/255.0, blue:230.0/255.0, alpha:1.0)
  end

  def markMarked
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    self.tintColor = nil
    self.backgroundColor = UIColor.colorWithRed(253.0/255.0, green:174.0/255.0, blue:87.0/255.0, alpha:1.0)
    self.name.color = UIColor.whiteColor
    self.info.color = UIColor.whiteColor
    self.timer.color = UIColor.whiteColor
    #self.enabled = false
  end

  def markFinished
    self.accessoryType = UITableViewCellAccessoryCheckmark
    self.tintColor = UIColor.whiteColor
    self.backgroundColor = UIColor.colorWithRed(117.0/255.0, green:157.0/255.0, blue:215.0/255.0, alpha:1.0)
    self.name.color = UIColor.whiteColor
    self.info.color = UIColor.whiteColor
    self.timer.color = UIColor.whiteColor
    #self.enabled = false
  end

  def willTransitionToState(state)
    super

    # Ready to edit...
    if state & UITableViewCellStateShowingEditControlMask == UITableViewCellStateShowingEditControlMask
      self.timer.alpha = 0.0
    end
  end

  def didTransitionToState(state)
    super

    # Finished with edit...
    if state & UITableViewCellStateShowingEditControlMask != UITableViewCellStateShowingEditControlMask
      UIView.animateWithDuration(0.5, animations: lambda {
        self.timer.alpha = 1.0
      })
    end
  end

end
