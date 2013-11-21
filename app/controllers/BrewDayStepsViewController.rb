class BrewDayStepsViewController < UIViewController

  extend IB

  attr_accessor :delegate, :brew, :path

  # Outlets
  outlet :name, UILabel
  outlet :info, UILabel
  outlet :brew_style, UILabel
  outlet :brew_info, UIButton
  outlet :table, UITableView

  def viewDidLoad
    super

    updateItems
    self.navigationItem.rightBarButtonItems = [self.navigationItem.rightBarButtonItem, self.editButtonItem]
  end

  def viewWillAppear(animated)
    table.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    name.text = self.brew.name
    info.text = self.brew.info
    brew_style.text = self.brew.brew_style.to_s
    super
  end

  def prepareForSegue(segue, sender:sender)
    vc = segue.destinationViewController

    case segue.identifier
    when 'BrewDayStepsInfoSegue'
      vc.delegate = self
      vc.brew_edit = self.brew
    when 'BrewDayStepsEditGroupSegue'
      self.path = table.indexPathForSelectedRow
      table.deselectRowAtIndexPath(self.path, animated:true)
      vc.delegate = self
      vc.group_edit = @items[self.path.row]
    when 'BrewDayStepsEditStepSegue'
      self.path = table.indexPathForSelectedRow
      table.deselectRowAtIndexPath(self.path, animated:true)
      vc.delegate = self
      vc.step_edit = @items[self.path.row]
    end
  end

  def updateItems
    @items = []
    brew.items.each { |item| @items.push item }

    # @@@@@ F*CK!  I shouldn't have to sort this!
    @items.sort! { |a,b| a.position <=> b.position }
  end

  def reorder(items)
    items.each_with_index do |item, i|
      item.position = i
      item.save!
    end

    updateItems
  end


  ############################################################################
  # Table View delegation

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    @items.count
  end
  
  def tableView(tableView, heightForRowAtIndexPath:path)
    item = @items[path.row]
    height = (item.is_a? StepTemplate) ? 44 : 30
  end

  def tableView(tableView, cellForRowAtIndexPath:path)
    cell = nil
    item = @items[path.row]

    case item
    when StepTemplate
      cell = tableView.dequeueReusableCellWithIdentifier(BrewDayStepCell.name)
    when GroupTemplate
      cell = tableView.dequeueReusableCellWithIdentifier(BrewDayGroupCell.name)
    end
    cell.populate(item)

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
      table.beginUpdates
      @items[index_path.row].destroy
      @items.delete_at(index_path.row)
      reorder(@items)    
      self.table.deleteRowsAtIndexPaths([index_path], withRowAnimation:UITableViewRowAnimationAutomatic)
      table.endUpdates
    end
  end

  def tableView(tableView, moveRowAtIndexPath:from_index_path, toIndexPath:to_index_path)
    item = @items[from_index_path.row]
    @items.delete_at(from_index_path.row)
    @items.insert(to_index_path.row, item)
    reorder(@items)    
  end

  def setEditing(is_editing, animated:is_animated)
    self.navigationItem.rightBarButtonItem.setEnabled(!is_editing)
    brew_info.setEnabled(!is_editing)
    self.table.setEditing(is_editing, animated:is_animated)
    super
  end

  # We do this to avoid having separators after the last cell
  def tableView(tableView, heightForFooterInSection:section)
    return 0.01
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
      bdv.delegate = self
      bdv.group_edit = nil
    when 1
      bdv = self.storyboard.instantiateViewControllerWithIdentifier('BrewDayAddStepView')
      bdv.delegate = self
    end

    # Add Step
    if bdv
      self.presentModalViewController(bdv, animated:true)
    end
  end


  ############################################################################
  # Delegate interface

  def stepPosition
    @items.count
  end

  def addGroupDone(brew_group)
    updateItems

    paths = [NSIndexPath.indexPathForRow(brew_group.position, inSection:0)]
    table.beginUpdates
    table.insertRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimationAutomatic)
    table.endUpdates
  end

  def editGroupDone(brew_group)
    updateItems

    cell = table.cellForRowAtIndexPath(self.path)
    cell.populate(brew_group)
  end

  def addStepDone(brew_step)
    updateItems

    paths = [NSIndexPath.indexPathForRow(brew_step.position, inSection:0)]
    table.beginUpdates
    table.insertRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimationAutomatic)
    table.endUpdates
  end

  def editStepDone(brew_step)
    updateItems

    cell = table.cellForRowAtIndexPath(self.path)
    cell.populate(brew_step)
  end

  def editBrewDone(brew)
    self.brew = brew
    self.delegate.editBrewDone(self.brew)
  end

end