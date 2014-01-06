class LoadTest

  BREWS = 
  [  
    { :name => 'Brew1', :info => 'Brew1 Info', :brew_style => 0, :position => 0, :groups =>
     [
       { :name => 'Group2', :hours => 0, :minutes => 0, :position => 1, :steps =>
         [
           { :name => 'Step2.3', :info => 'Step3 Info', :hours => 0, :minutes => 0, :position => 2 },
           { :name => 'Step2.2', :info => 'Step2 Info', :hours => 0, :minutes => 0, :position => 1 },
           { :name => 'Step2.1', :info => 'Step1 Info', :hours => 0, :minutes => 0, :position => 0 }
         ]
       },
       { :name => 'Group1', :hours => 0, :minutes => 0, :position => 0, :steps =>
         [ 
           { :name => 'Step1.2', :info => 'Step2 Info', :hours => 0, :minutes => 0, :position => 1 },
           { :name => 'Step1.1', :info => 'Step1 Info', :hours => 0, :minutes => 0, :position => 0 },
           { :name => 'Step1.3', :info => 'Step3 Info', :hours => 0, :minutes => 0, :position => 2 }
         ]
       },
       { :name => 'Group3', :hours => 0, :minutes => 0, :position => 2, :steps =>
         [ 
           { :name => 'Step3.2', :info => 'Step2 Info', :hours => 0, :minutes => 0, :position => 1 },
           { :name => 'Step3.1', :info => 'Step1 Info', :hours => 0, :minutes => 0, :position => 0 },
           { :name => 'Step3.3', :info => 'Step3 Info', :hours => 0, :minutes => 0, :position => 2 }
         ]
       }
     ]
    },
    { :name => 'Brew2', :info => 'Brew2 Info', :brew_style => 0, :position => 0, :groups =>
     [
       { :name => 'Group1', :hours => 0, :minutes => 0, :position => 0, :steps =>
         [  
           { :name => 'Step1', :info => 'Step1 Info', :hours => 0, :minutes => 0, :position => 0 },
           { :name => 'Step2', :info => 'Step2 Info', :hours => 0, :minutes => 0, :position => 1 },
           { :name => 'Step3', :info => 'Step3 Info', :hours => 0, :minutes => 0, :position => 2 }
         ]
       },
       { :name => 'Group2', :hours => 0, :minutes => 0, :position => 1, :steps =>
         [  
           { :name => 'Step1', :info => 'Step1 Info', :hours => 0, :minutes => 0, :position => 0 },
           { :name => 'Step2', :info => 'Step2 Info', :hours => 0, :minutes => 0, :position => 1 },
           { :name => 'Step3', :info => 'Step3 Info', :hours => 0, :minutes => 0, :position => 2 }
         ]
       }
     ]
    }
  ]

  def self.load
    ctx = App.delegate.managedObjectContext
    BREWS.each do |brew|
      bt = BrewTemplate.new(name: brew[:name],
                            info: brew[:info],
                            brew_style: brew[:brew_style],
                            position: brew[:position])
      bt.save!
      brew[:groups].each do |group|
        gt = GroupTemplate.new(name: group[:name],
                               hours: group[:hours],
                               minutes: group[:minutes],
                               position: group[:position])
        ctx.insertObject(gt)
        gt.brew = bt
        gt.save!
        group[:steps].each do |step|
          st = StepTemplate.new(name: step[:name],
                                info: step[:info],
                                hours: step[:hours],
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
