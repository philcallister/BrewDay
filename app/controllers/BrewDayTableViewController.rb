class BrewDayTableViewController < UITableViewController

  extend IB

  # Outlets
  outlet :table, UITableView

  def viewDidLoad
    super

    @menu = [{ :name => "Pablo's Hopalong", :description => "Bell's Hopslam clone...Oh it's good! It's so so so good!!!", :func => nil, :params => { :id => 'RecipeView' } },
             { :name => "Paranoid Coffee Milk Stout", :description => "Wat? This won 3rd place at Beer Dabler 2013.", :func => nil, :params => { :id => 'RecipeView' } },
             { :name => "Phil's Furious", :description => "Surly Furious in your own keg.", :func => nil, :params => { :id => 'RecipeView' } }]

    self.navigationItem.rightBarButtonItems = [self.navigationItem.rightBarButtonItem, self.editButtonItem]
  end

  def viewWillAppear(animated)
    super
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def prepareForSegue(segue, sender:sender)
    if (segue.identifier == 'BrewDayAddSegue')
      bdac = segue.destinationViewController
      bdac.delegate = self
    end
  end

  def setEditing(is_editing, animated:is_animated)
    puts ">>>>> MenuTableViewController#setEditing: #{is_editing}"
    self.tableView.setEditing(is_editing, animated:is_animated)
    super
  end


  ############################################################################
  # Table View delegation

  def tableView(tableView, numberOfRowsInSection:section)
    @menu.count
  end
  
  def tableView(tableView, cellForRowAtIndexPath:path)
    item = @menu[path.row]
    cell = tableView.dequeueReusableCellWithIdentifier(BrewDayCell.name)
    cell.name.text = item[:name]
    cell.description.text = item[:description]
    cell.description.sizeToFit

    bgColorView = UIView.alloc.init
    bgColorView.backgroundColor = UIColor.colorWithRed(220.0/255.0, green:220.0/255.0, blue:220.0/255.0, alpha:1.0)
    cell.selectedBackgroundView = bgColorView
    color = UIColor.colorWithRed(95.0/255.0, green:125.0/255.0, blue:54.0/255.0, alpha:1.0)
    cell.name.highlightedTextColor = color
    cell.description.highlightedTextColor = color

    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:path)
    item = @menu[path.row]
    if item[:func]
      if self.respond_to?(item[:func])
        if item[:params]
          self.send(item[:func], item[:params])
        else
          self.send(item[:func])
        end
      end
    end
  end

  def tableView(tableView, commitEditingStyle:editing_style, forRowAtIndexPath:index_path)
    puts ">>>>> MenuTableViewController#commitEditingStyle"
    if editing_style == UITableViewCellEditingStyleDelete
      editing_style = "UITableViewCellEditingStyleDelete"
      # @players.delete_at(index_path.row)
      # @table_view.deleteRowsAtIndexPaths([index_path], withRowAnimation:UITableViewRowAnimationAutomatic)
      # self.playersChanged(false)
    end
  end

  def tableView(tableView, moveRowAtIndexPath:from_index_path, toIndexPath:to_index_path)
    puts ">>>>> MenuTableViewController#moveRowAtIndexPath"
    # @move = @players[from_index_path.row]
    # @players.delete_at(from_index_path.row)
    # if @move
    #   @players.insert(to_index_path.row, @move)
    #   self.playersChanged(false)
    # end
  end


  ############################################################################
  # Actions

  def menuPressed
    self.slidingViewController.anchorTopViewTo(ECRight)
  end


  ############################################################################
  # Delegate interface

  def addDone(brew_day)
    puts "addDone => Name: #{brew_day.name} | Description: #{brew_day.description} | Type: #{brew_day.brew_type}"
    @menu << { :name => brew_day.name, :description => brew_day.description, :func => nil, :params => { :id => 'RecipeView' } }
    paths = [NSIndexPath.indexPathForRow(@menu.length - 1, inSection:0)]
    table.beginUpdates
    table.insertRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimationAutomatic)
    table.endUpdates
  end

end