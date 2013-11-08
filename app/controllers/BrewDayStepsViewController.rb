class BrewDayStepsViewController < UIViewController

  extend IB

  # Outlets
  outlet :name, UILabel
  outlet :description, UILabel
  outlet :table, UITableView

  def viewDidLoad
    super

    @steps = [{ :type => BrewDayGroupCell.name, :name => "Start", :func => nil, :params => { :id => 'BrewDayAddGroupView' } },
              { :type => BrewDayStepCell.name, :name => "HLT", :description => "Heat 8 gallons HLT to 154F but DO NOT GO OVER!!", :timer => "0:30", :func => nil, :params => { :id => 'BrewDayAddStepView' } },
              { :type => BrewDayStepCell.name, :name => "Transfer", :description => "Transfer HLT to Mash Tun", :timer => nil, :func => nil, :params => { :id => 'BrewDayAddStepView' } },
              { :type => BrewDayStepCell.name, :name => "Mash-in", :description => "Mash-in all 60-minute grain", :timer => "0:15", :func => nil, :params => { :id => 'BrewDayAddStepView' } },
              { :type => BrewDayGroupCell.name, :name => "Mash", :func => nil, :params => { :id => 'BrewDayAddGroupView' } },
              { :type => BrewDayStepCell.name, :name => "PH", :description => "Test PH...want on low side (5.2)", :timer => nil, :func => nil, :params => { :id => 'BrewDayAddStepView' } },
              { :type => BrewDayStepCell.name, :name => "Sacch Rest", :description => "Sacch Rest @ 152F for 1 hour", :timer => "1:00", :func => nil, :params => { :id => 'BrewDayAddStepView' } }]

    r1 = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAdd,
                                                           target: self,
                                                           action: :addPressed)
    r2 = self.editButtonItem
    self.navigationItem.rightBarButtonItems = [r1, r2]
  end

  def viewWillAppear(animated)
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
      cell.description.text = item[:description]
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
    puts ">>>>> Pressed: #{buttonIndex}"
  end


  ############################################################################
  # Delegate interface

end