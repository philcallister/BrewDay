class LoadTest

  BREWS = 
  [  
    { :name => 'Brew1', :info => 'Brew1 Info', :brew_style => 0, :position => 0, :groups =>
     [
       { :name => 'Group2', :minutes => 0, :position => 1, :steps =>
         [
           { :name => 'Step2.3', :info => 'Step3 Info', :step_type => 0, :minutes => 0, :position => 2 },
           { :name => 'Step2.2', :info => 'Step2 Info', :step_type => 0, :minutes => 0, :position => 1 },
           { :name => 'Step2.1', :info => 'Step1 Info', :step_type => 0, :minutes => 0, :position => 0 }
         ]
       },
       { :name => 'Group1', :minutes => 0, :position => 0, :steps =>
         [ 
           { :name => 'Step1.2', :info => 'Step2 Info', :step_type => 0, :minutes => 0, :position => 1 },
           { :name => 'Step1.1', :info => 'Step1 Info', :step_type => 0, :minutes => 0, :position => 0 },
           { :name => 'Step1.3', :info => 'Step3 Info', :step_type => 0, :minutes => 0, :position => 2 }
         ]
       },
       { :name => 'Group3', :minutes => 0, :position => 2, :steps =>
         [ 
           { :name => 'Step3.2', :info => 'Step2 Info', :step_type => 0, :minutes => 0, :position => 1 },
           { :name => 'Step3.1', :info => 'Step1 Info', :step_type => 0, :minutes => 0, :position => 0 },
           { :name => 'Step3.3', :info => 'Step3 Info', :step_type => 0, :minutes => 0, :position => 2 }
         ]
       }
     ]
    },
    { :name => 'Brew2', :info => 'Brew2 Info', :brew_style => 1, :position => 0, :groups =>
     [
       { :name => 'Group1', :minutes => 0, :position => 0, :steps =>
         [  
           { :name => 'Step1', :info => 'Step1 Info', :step_type => 0, :minutes => 0, :position => 0 },
           { :name => 'Step2', :info => 'Step2 Info', :step_type => 0, :minutes => 0, :position => 1 },
           { :name => 'Step3', :info => 'Step3 Info', :step_type => 0, :minutes => 0, :position => 2 }
         ]
       },
       { :name => 'Group2', :minutes => 0, :position => 1, :steps =>
         [  
           { :name => 'Step1', :info => 'Step1 Info', :step_type => 0, :minutes => 0, :position => 0 },
           { :name => 'Step2', :info => 'Step2 Info', :step_type => 0, :minutes => 0, :position => 1 },
           { :name => 'Step3', :info => 'Step3 Info', :step_type => 0, :minutes => 0, :position => 2 }
         ]
       }
     ]
    },
    { :name => 'Brew3', :info => 'Brew3 Info', :brew_style => 2, :position => 0, :groups => nil },
    { :name => 'Brew4', :info => 'Brew4 Info', :brew_style => 3, :position => 0, :groups => nil },
    { :name => 'Brew5', :info => 'Brew5 Info', :brew_style => 4, :position => 0, :groups => nil },
    { :name => 'Brew6', :info => 'Brew6 Info', :brew_style => 5, :position => 0, :groups => nil },
    { :name => 'Brew7', :info => 'Brew7 Info', :brew_style => 6, :position => 0, :groups => nil },
    { :name => 'Brew8', :info => 'Brew8 Info', :brew_style => 7, :position => 0, :groups => nil },
    { :name => 'Brew9', :info => 'Brew9 Info', :brew_style => 8, :position => 0, :groups => nil },
    { :name => 'Brew10', :info => 'Brew10 Info', :brew_style => 9, :position => 0, :groups => nil }
  ]

  def self.load
    ctx = App.delegate.managedObjectContext
    BREWS.each do |brew|
      bt = BrewTemplate.new(name: brew[:name],
                            info: brew[:info],
                            brew_style: brew[:brew_style],
                            position: brew[:position])
      bt.save!
      unless brew[:groups].nil?
        brew[:groups].each do |group|
          gt = GrpTemplate.new(name: group[:name],
                               minutes: group[:minutes],
                               position: group[:position])
          ctx.insertObject(gt)
          gt.brew = bt
          gt.save!
          unless group[:steps].nil?
            group[:steps].each do |step|
              st = StepTemplate.new(name: step[:name],
                                    info: step[:info],
                                    minutes: step[:minutes],
                                    position: step[:position])
              ctx.insertObject(st)
              st.group = gt
              st.save!
            end
          end
        end
      end
    end
  end

end
