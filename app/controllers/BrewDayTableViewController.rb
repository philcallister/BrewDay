class BrewDayTableViewController < UITableViewController

  #include BW::KVO

  extend IB

  attr_accessor :path

  # Outlets
  outlet :table, UITableView

  def viewDidLoad
    super

    updateBrews
    self.navigationItem.rightBarButtonItems = [self.navigationItem.rightBarButtonItem, self.editButtonItem]
  end

  def viewWillAppear(animated)
    # table.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    super
  end

  def prepareForSegue(segue, sender:sender)
    vc = segue.destinationViewController

    case segue.identifier
    # Add Brew
    when 'BrewDayAddSegue'
      vc.delegate = self
      vc.brew_edit = nil
    # Brew Steps
    when 'BrewDayStepsSegue'
      self.path = table.indexPathForSelectedRow
      vc.delegate = self
      vc.brew = @brews[self.path.row]
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

  # def observeBrewChanges
  #   self.brew.modify = 0

  #   unobserve(self.brew, "modify")
  #   observe(self.brew, "modify") do |old_value, new_value|
  #     cell = table.cellForRowAtIndexPath(self.path)
  #     puts ">>>>> Old: #{old_value} | New: #{new_value}"
  #     puts "+++++ Cell: #{cell.name.text} | Model: #{self.brew.name}"
  #     puts "+++++ Cell: #{cell.info.text} | Model: #{self.brew.info}"
  #     puts "+++++ Cell: #{cell.brew_style.text} | Model: #{self.brew.brew_style}"
  #     # cell.name.text = @brew.name
  #     # cell.info.text = @brew.info
  #     # cell.brew_style.text = @brew.brew_style.to_s
  #   end
  # end


  ############################################################################
  # Table View delegation

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    @brews.count
  end
  
  def tableView(tableView, cellForRowAtIndexPath:path)
    item = @brews[path.row]
    cell = tableView.dequeueReusableCellWithIdentifier(BrewDayCell.name)
    cell.populate(item)
    cell
  end

  def tableView(tableView, commitEditingStyle:editing_style, forRowAtIndexPath:index_path)
    if editing_style == UITableViewCellEditingStyleDelete
      table.beginUpdates
      brews = Array.new(@brews)
      brews[index_path.row].destroy
      brews.delete_at(index_path.row)
      reorder(brews)    
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

  def addBrewDone(brew)
    updateBrews

    paths = [NSIndexPath.indexPathForRow(brew.position, inSection:0)]
    table.beginUpdates
    table.insertRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimationAutomatic)
    table.endUpdates
  end

  def editBrewDone(brew)
    updateBrews

    cell = table.cellForRowAtIndexPath(self.path)
    cell.name.text = brew.name
    cell.info.text = brew.info
    cell.brew_style.text = brew.brew_style.to_s
  end

end