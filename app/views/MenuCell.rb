class MenuCell < UITableViewCell

  extend IB

  # outlet
  outlet :menu, UILabel

  def populate(menu)
    self.menu.text = menu

    bgColorView = UIView.alloc.init
    bgColorView.backgroundColor = UIColor.colorWithRed(182.0/255.0, green:182.0/255.0, blue:182.0/255.0, alpha:1.0)
    self.selectedBackgroundView = bgColorView
    self.menu.highlightedTextColor = UIColor.whiteColor
  end
  
end