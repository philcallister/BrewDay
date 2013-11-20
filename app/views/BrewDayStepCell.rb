class BrewDayStepCell < UITableViewCell

  extend IB

  # Outlets
  outlet :name, UILabel
  outlet :info, UILabel
  outlet :timer, UILabel

  def populate(item)
    self.name.text = item.name
    self.info.text = item.info
    self.timer.text = item.is_event? ? nil : "#{item.hours}:#{format('%02d', item.minutes)}"

    bgColorView = UIView.alloc.init
    bgColorView.backgroundColor = UIColor.colorWithRed(182.0/255.0, green:182.0/255.0, blue:182.0/255.0, alpha:1.0)
    self.selectedBackgroundView = bgColorView
    color = UIColor.whiteColor
    self.name.highlightedTextColor = color
    self.info.highlightedTextColor = color
    self.timer.highlightedTextColor = UIColor.whiteColor
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
