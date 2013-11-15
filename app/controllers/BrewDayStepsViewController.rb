class BrewDayStepsViewController < UIViewController

  extend IB

  attr_accessor :brew

  # Outlets
  outlet :name, UILabel
  outlet :info, UILabel
  outlet :brew_style, UILabel
  outlet :table, UITableView

  def viewDidLoad
    super

    @steps = [{ :type => BrewDayGroupCell.name, :name => "Start", :func => nil, :params => { :id => 'BrewDayAddGroupView' } },
              { :type => BrewDayStepCell.name, :name => "HLT", :info => "Heat 8 gallons HLT to 154F but DO NOT GO OVER!!", :timer => "0:30", :func => nil, :params => { :id => 'BrewDayAddStepView' } },
              { :type => BrewDayStepCell.name, :name => "Transfer", :info => "Transfer HLT to Mash Tun", :timer => nil, :func => nil, :params => { :id => 'BrewDayAddStepView' } },
              { :type => BrewDayStepCell.name, :name => "Mash-in", :info => "Mash-in all 60-minute grain", :timer => "0:15", :func => nil, :params => { :id => 'BrewDayAddStepView' } },
              { :type => BrewDayGroupCell.name, :name => "Mash", :func => nil, :params => { :id => 'BrewDayAddGroupView' } },
              { :type => BrewDayStepCell.name, :name => "PH", :info => "Test PH...want on low side (5.2)", :timer => nil, :func => nil, :params => { :id => 'BrewDayAddStepView' } },
              { :type => BrewDayStepCell.name, :name => "Sacch Rest", :info => "Sacch Rest @ 152F for 1 hour", :timer => "1:00", :func => nil, :params => { :id => 'BrewDayAddStepView' } }]
    self.navigationItem.rightBarButtonItems = [self.navigationItem.rightBarButtonItem, self.editButtonItem]
  end

  def viewWillAppear(animated)
    name.text = brew.name
    info.text = brew.info
    brew_style.text = brew.brew_style.to_s
    super
  end


  ############################################################################
  # Table View delegation

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    @steps.count
  end
  
  def tableView(tableView, titleForHeaderInSection:section)
  end

  def tableView(tableView, heightForRowAtIndexPath:path)
    item = @steps[path.row]
    height = (item[:type] == BrewDayStepCell.name) ? 44 : 30
  end

  def tableView(tableView, cellForRowAtIndexPath:path)
    cell = nil
    item = @steps[path.row]

    case item[:type]
    when BrewDayStepCell.name
      cell = tableView.dequeueReusableCellWithIdentifier(item[:type])
      cell.name.text = item[:name]
      cell.info.text = item[:info]
      cell.timer.text = item[:timer]
    when BrewDayGroupCell.name
      cell = tableView.dequeueReusableCellWithIdentifier(item[:type])
      cell.name.text = item[:name]
    end

    bgColorView = UIView.alloc.init
    bgColorView.backgroundColor = UIColor.colorWithRed(220.0/255.0, green:220.0/255.0, blue:220.0/255.0, alpha:1.0)
    cell.selectedBackgroundView = bgColorView
    color = UIColor.colorWithRed(95.0/255.0, green:125.0/255.0, blue:54.0/255.0, alpha:1.0)
    cell.name.highlightedTextColor = color

    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:path)
    # item = @menu[path.row]
    # if item[:func]
    #   if self.respond_to?(item[:func])
    #     if item[:params]
    #       self.send(item[:func], item[:params])
    #     else
    #       self.send(item[:func])
    #     end
    #   end
    # end
  end

  def tableView(tableView, commitEditingStyle:editing_style, forRowAtIndexPath:index_path)
    if editing_style == UITableViewCellEditingStyleDelete
      editing_style = "UITableViewCellEditingStyleDelete"
    end
  end

  def tableView(tableView, moveRowAtIndexPath:from_index_path, toIndexPath:to_index_path)
    puts ">>>>> MenuTableViewController#moveRowAtIndexPath"
  end

  def setEditing(is_editing, animated:is_animated)
    self.table.setEditing(is_editing, animated:is_animated)
    super
  end

  def tableView(tableView, editingStyleForRowAtIndexPath:path)
    item = @steps[path.row]
    if item[:type] == BrewDayStepCell.name
    end

    UITableViewCellEditingStyleDelete
  end


  ############################################################################
  # Actions

  def addPressed
    sheet = UIActionSheet.alloc.initWithTitle(nil,
                                              delegate:self,
                                              cancelButtonTitle:"Cancel",
                                              destructiveButtonTitle:nil,
                                              otherButtonTitles:"Add Group", "Add Step", nil)
    sheet.showInView(self.view)
  end

  def actionSheet(actionSheet, didDismissWithButtonIndex:buttonIndex)
    bdv = nil
    case buttonIndex
    when 0
      bdv = self.storyboard.instantiateViewControllerWithIdentifier('BrewDayAddGroupView')
    when 1
      bdv = self.storyboard.instantiateViewControllerWithIdentifier('BrewDayAddStepView')
    end

    # Add Step
    if bdv
      bdv.delegate = self
      self.presentModalViewController(bdv, animated:true)
    end

  end


  ############################################################################
  # Delegate interface

  def addGroupDone(brew_group)
    @steps << { :type => BrewDayGroupCell.name, :name => brew_group.name, :func => nil, :params => { :id => 'RecipeView' } }
    paths = [NSIndexPath.indexPathForRow(@steps.length - 1, inSection:0)]
    table.beginUpdates
    table.insertRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimationAutomatic)
    table.endUpdates
  end

  def addStepDone(brew_step)
    @steps << { :type => BrewDayStepCell.name, :name => brew_step.name, :info => brew_step.description, :func => nil, :params => { :id => 'RecipeView' } }
    paths = [NSIndexPath.indexPathForRow(@steps.length - 1, inSection:0)]
    table.beginUpdates
    table.insertRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimationAutomatic)
    table.endUpdates
  end

end