class BrewDayTableViewController < UITableViewController

  extend IB

  # Outlets
  outlet :table, UITableView

  def viewDidLoad
    super

    updateBrews
    self.navigationItem.rightBarButtonItems = [self.navigationItem.rightBarButtonItem, self.editButtonItem]
  end

  def viewWillAppear(animated)
    super
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def prepareForSegue(segue, sender:sender)
    vc = segue.destinationViewController

    case segue.identifier
    # Add Brew
    when 'BrewDayAddSegue'
      vc.delegate = self
    # Brew Steps
    when 'BrewDayStepsSegue'
      path = table.indexPathForSelectedRow
      vc.brew = @brews[path.row]
    end
  end

  def setEditing(is_editing, animated:is_animated)
    self.navigationItem.rightBarButtonItem.setEnabled(!is_editing)
    self.navigationItem.leftBarButtonItem.setEnabled(!is_editing)
    super
  end

  def updateBrews
    @brews = BrewTemplate.order(:position).all
  end

  def reorder(brews)
    brews.each_with_index do |brew, i|
      brew.position = i
      brew.save!
    end

    updateBrews
  end


  ############################################################################
  # Table View delegation

  def tableView(tableView, numberOfRowsInSection:section)
    @brews.count
  end
  
  def tableView(tableView, cellForRowAtIndexPath:path)
    item = @brews[path.row]
    cell = tableView.dequeueReusableCellWithIdentifier(BrewDayCell.name)
    cell.populate(item.name, item.info, item.brew_style)
    cell
  end

  def tableView(tableView, commitEditingStyle:editing_style, forRowAtIndexPath:index_path)
    if editing_style == UITableViewCellEditingStyleDelete
      editing_style = "UITableViewCellEditingStyleDelete"
      brews = Array.new(@brews)
      brews[index_path.row].destroy
      brews.delete_at(index_path.row)
      reorder(brews)    

      table.beginUpdates
      self.table.deleteRowsAtIndexPaths([index_path], withRowAnimation:UITableViewRowAnimationAutomatic)
      table.endUpdates
    end
  end

  def tableView(tableView, moveRowAtIndexPath:from_index_path, toIndexPath:to_index_path)
    brews = Array.new(@brews)
    brew = brews[from_index_path.row]
    brews.delete_at(from_index_path.row)
    brews.insert(to_index_path.row, brew)
    reorder(brews)    
  end

  # We do this to avoid having separators after the last cell
  def tableView(tableView, heightForFooterInSection:section)
    return 0.01
  end


  ############################################################################
  # Actions

  def menuPressed
    self.slidingViewController.anchorTopViewTo(ECRight)
  end


  ############################################################################
  # Delegate interface

  def brewPosition
    @brews.count
  end

  def addDone(brew)
    updateBrews

    paths = [NSIndexPath.indexPathForRow(brew.position, inSection:0)]
    table.beginUpdates
    table.insertRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimationAutomatic)
    table.endUpdates
  end

end