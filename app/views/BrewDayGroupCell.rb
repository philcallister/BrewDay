class BrewDayGroupCell < UITableViewCell

  extend IB

  # Outlets
  outlet :name, UILabel
  outlet :timer, UILabel
  outlet :info, UIButton

  def populate(item)
    self.name.text = item.name
    self.timer.text = item.group_text

    color = UIColor.whiteColor
    self.name.highlightedTextColor = color
    self.timer.highlightedTextColor = UIColor.whiteColor

    markGroup(item)

    view = UIView.alloc.initWithFrame(self.frame)
    view.addSubview(self)
    view  
  end

  def markGroup(item)
    if item.is_a? Grp
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
    self.backgroundColor = UIColor.colorWithRed(240.0/255.0, green:239.0/255.0, blue:241.0/255.0, alpha:1.0)
    self.name.color = UIColor.colorWithRed(12.0/255.0, green:97.0/255.0, blue:146.0/255.0, alpha:1.0)
    self.timer.color = UIColor.colorWithRed(91.0/255.0, green:179.0/255.0, blue:230.0/255.0, alpha:1.0)
    self.info.enabled = true
  end

  def markMarked
    self.backgroundColor = UIColor.colorWithRed(253.0/255.0, green:174.0/255.0, blue:87.0/255.0, alpha:1.0)
    self.name.color = UIColor.whiteColor
    self.timer.color = UIColor.whiteColor
    self.info.enabled = false
  end

  def markFinished
    self.backgroundColor = UIColor.colorWithRed(117.0/255.0, green:157.0/255.0, blue:215.0/255.0, alpha:1.0)
    self.name.color = UIColor.colorWithRed(205.0/255.0, green:205.0/255.0, blue:205.0/255.0, alpha:1.0)
    self.timer.color = UIColor.colorWithRed(205.0/255.0, green:205.0/255.0, blue:205.0/255.0, alpha:1.0)
    #self.name.color = UIColor.colorWithRed(3.0/255.0, green:49.0/255.0, blue:81.0/255.0, alpha:1.0)
    #self.timer.color = UIColor.colorWithRed(3.0/255.0, green:49.0/255.0, blue:81.0/255.0, alpha:1.0)
    self.info.enabled = false
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