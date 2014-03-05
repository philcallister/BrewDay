class BrewDayTableViewController < UITableViewController

  #include BW::KVO

  extend IB

  attr_accessor :path

  # Outlets
  outlet :table, UITableView

  def viewDidLoad
    super

    @editing = false
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
    # Steps
    when 'BrewDayStepsSegue'
      self.path = self.table.indexPathForSelectedRow
      vc.delegate = self
      vc.brew = @brew_templates[self.path.row]
    # Brew
    when 'BrewDayBrewSegue'
      self.path = self.table.indexPathForSelectedRow
      vc.delegate = self
      vc.brew = @brew_templates[self.path.row].brew_create_or_get_unfinished
    end
  end

  def setEditing(is_editing, animated:is_animated)
    @editing = is_editing
    self.navigationItem.rightBarButtonItem.setEnabled(!is_editing)
    self.navigationItem.leftBarButtonItem.setEnabled(!is_editing)
    super
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
    @brew_templates.count
  end
  
  def tableView(tableView, cellForRowAtIndexPath:path)
    item = @brew_templates[path.row]
    cell = tableView.dequeueReusableCellWithIdentifier(BrewDayCell.name)
    cell.populate(item)

    # Save the row for later lookup when utility button is clicked
    cell.info.tag = path.row

    # Utility button setup
    cell.containingTableView = tableView
    cell.setCellHeight(cell.frame.size.height)
    right_buttons = NSMutableArray.new
    #right_buttons.sw_addUtilityButtonWithColor(UIColor.colorWithRed(198.0/255.0, green:198.0/255.0, blue:198.0/255.0, alpha:1.0), title:'Edit')
    right_buttons.sw_addUtilityButtonWithColor(UIColor.colorWithRed(89.0/255.0, green:162.0/255.0, blue:12.0/255.0, alpha:1.0), title:'Brew')
    right_buttons.sw_addUtilityButtonWithColor(UIColor.colorWithRed(12.0/255.0, green:89.0/255.0, blue:162.0/255.0, alpha:1.0), title:'Log')
    right_buttons.sw_addUtilityButtonWithColor(UIColor.colorWithRed(255.0/255.0, green:59.0/255.0, blue:48.0/255.0, alpha:1.0), title:'Delete')
    cell.rightUtilityButtons = right_buttons
    cell.delegate = self

    # @@@@@ There's no way I can find to disable selection while editing with
    # SWTableViewCell.  So...we'll grab the GestureRecognizers and will
    # ignore them while editing.
    cell.longPressGestureRecognizer.delegate = self
    cell.tapGestureRecognizer.delegate = self

    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:path)
    tableView.selectRowAtIndexPath(path, animated:true, scrollPosition:UITableViewScrollPositionNone)
    self.performSegueWithIdentifier("BrewDayStepsSegue", sender:self)
  end

  def tableView(tableView, editingStyleForRowAtIndexPath:path)
    return UITableViewCellEditingStyleNone
  end

  def tableView(tableView, shouldIndentWhileEditingRowAtIndexPath:path)
    false
  end

  # def tableView(tableView, commitEditingStyle:editing_style, forRowAtIndexPath:index_path)
  #   if editing_style == UITableViewCellEditingStyleDelete
  #     deleteBrew(index_path)
  #   end
  # end

  def tableView(tableView, moveRowAtIndexPath:from_index_path, toIndexPath:to_index_path)
    brews = Array.new(@brew_templates)
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
  # Swipe Delegate

  def swipeableTableViewCell(cell, didTriggerLeftUtilityButtonWithIndex:index)
  end

  def swipeableTableViewCell(cell, didTriggerRightUtilityButtonWithIndex:index)
    path = NSIndexPath.indexPathForRow(cell.info.tag, inSection:0)
    case index
    when 0
      tableView.selectRowAtIndexPath(path, animated:true, scrollPosition:UITableViewScrollPositionNone)
      self.performSegueWithIdentifier("BrewDayBrewSegue", sender:self)
    when 1
      puts "!!!!! LOG !!!!!"
    when 2
      deleteBrew(path)
    end
  end

  def swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell)
    true
  end

  def swipeableTableViewCell(cell, scrollingToState:state)
  end

  def swipeableTableViewCell(cell, canSwipeToState:state)
    !@editing
  end

  def gestureRecognizerShouldBegin(gestureRecognizer)
    !@editing
  end

  ############################################################################
  # Actions

  def menuPressed
    self.slidingViewController.anchorTopViewTo(ECRight)
  end


  ############################################################################
  # Delegate interface

  def brewPosition
    @brew_templates.count
  end

  def addBrewDone(brew)
    updateBrews

    paths = [NSIndexPath.indexPathForRow(brew.position, inSection:0)]
    table.beginUpdates
    table.insertRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimationAutomatic)
    table.endUpdates
  end

  def editBrewDone(brew)
    self.table.reloadData
  end


  ############################################################################
  # Internal

  private

    def updateBrews
      @brew_templates = BrewTemplate.order(:position).all
    end

    def reorder(brews)
      brews.each_with_index do |brew, i|
        brew.position = i
        brew.save!
      end
      updateBrews
    end

    def deleteBrew(index_path)
      #self.table.beginUpdates
      brews = Array.new(@brew_templates)
      brews[index_path.row].destroy
      brews.delete_at(index_path.row)
      reorder(brews)    
      #self.table.deleteRowsAtIndexPaths([index_path], withRowAnimation:UITableViewRowAnimationAutomatic)
      #self.table.endUpdates
      self.table.reloadData
    end

end
