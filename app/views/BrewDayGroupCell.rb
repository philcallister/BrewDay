class BrewDayGroupCell < UITableViewCell

  extend IB

  # Outlets
  outlet :name, UILabel

  def populate(item)
    self.name.text = item.name

    bgColorView = UIView.alloc.init
    bgColorView.backgroundColor = UIColor.colorWithRed(182.0/255.0, green:182.0/255.0, blue:182.0/255.0, alpha:1.0)
    self.selectedBackgroundView = bgColorView
    color = UIColor.whiteColor
    self.name.highlightedTextColor = color
  end


end