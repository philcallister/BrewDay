class BrewDayCell < UITableViewCell

  extend IB

  # Outlets
  outlet :name, UILabel
  outlet :info, UILabel
  outlet :brew_style, UILabel
  outlet :brew_style_view, UIView

  def populate(item)
    self.name.text = item.name
    self.info.text = item.info
    self.brew_style.text = item.brew_style.to_s

    bgColorView = UIView.alloc.init
    bgColorView.backgroundColor = UIColor.colorWithRed(182.0/255.0, green:182.0/255.0, blue:182.0/255.0, alpha:1.0)
    self.selectedBackgroundView = bgColorView
    color = UIColor.whiteColor
    self.name.highlightedTextColor = color
    self.info.highlightedTextColor = color
    self.brew_style.highlightedTextColor = UIColor.whiteColor
    self.brew_style_view.layer.cornerRadius = 7
  end

  def setSelected(selected, animated:animated)
    @background ||= self.brew_style_view.backgroundColor
    super
    self.brew_style_view.backgroundColor = @background
  end

  def setHighlighted(highlighted, animated:animated)
    @background ||= self.brew_style_view.backgroundColor
    super
    self.brew_style_view.backgroundColor = @background
  end

end