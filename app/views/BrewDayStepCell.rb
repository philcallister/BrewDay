class BrewDayStepCell < UITableViewCell

  extend IB

  # Outlets
  outlet :name, UILabel
  outlet :info, UILabel
  outlet :timer, UILabel

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
