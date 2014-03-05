class Brew < MotionDataWrapper::Model

  # name
  # info
  # brew_style
  # date
  # note
  # finished
  # template => to one
  # groups => to many

  YES = 1
  NO = 0

  # Return a new Brew using the given BrewTemplate.  This builder
  # will clone all the groups and steps necessary to create a new Brew.
  def self.brew_builder(brew_template)
    brew = Brew.new(name: brew_template.name,
                    info: brew_template.info,
                    brew_style: brew_template.brew_style,
                    date: Time.now,
                    finished: Brew::NO)
    ctx = App.delegate.managedObjectContext
    ctx.insertObject(brew)
    brew.template = brew_template
    brew.save!
    # groups
    brew_template.groups.each do |gt|
      group = Grp.new(name: gt.name,
                      minutes: gt.minutes,
                      position: gt.position)
      ctx.insertObject(group)
      group.brew = brew
      group.save!
      # steps
      gt.steps.each do |st|
        step = Step.new(name: st.name,
                        info: st.info,
                        step_type: st.step_type,
                        minutes: st.minutes,
                        position: st.position)
        ctx.insertObject(step)
        step.group = group
        step.save!
      end
    end
    brew
  end
  
end