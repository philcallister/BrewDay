class BrewTemplate < MotionDataWrapper::Model

  # name
  # info
  # brew_style
  # position
  # groups => to many
  # brews => to many

  def brew_create_or_get_unfinished
    self.brews.each do |b|
      return b unless b.finished == Brew::YES
    end
    return Brew.brew_builder(self)
  end

end