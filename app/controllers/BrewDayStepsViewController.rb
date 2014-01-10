class BrewDayStepsViewController < UIViewController

  extend IB

  attr_accessor :delegate, :brew, :path

  # Outlets
  outlet :name, UILabel
  outlet :info, UILabel
  outlet :brew_style_view, UIView
  outlet :brew_style, UILabel
  outlet :brew_info, UIButton
  outlet :table, UITableView


  def viewDidLoad
    super

    updateItems
    self.navigationItem.rightBarButtonItems = [self.navigationItem.rightBarButtonItem, self.editButtonItem]
  end

  def viewWillAppear(animated)
    #self.table.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    self.name.text = self.brew.name
    self.info.text = self.brew.info
    self.brew_style.text = self.brew.brew_style.to_s
    self.brew_style_view.layer.cornerRadius = 7

    super
  end

  def prepareForSegue(segue, sender:sender)
    vc = segue.destinationViewController

    case segue.identifier
    when 'BrewDayStepsInfoSegue'
      vc.delegate = self
      vc.brew_edit = self.brew
    when 'BrewDayStepsEditStepSegue'
      self.path = table.indexPathForSelectedRow
      self.table.deselectRowAtIndexPath(self.path, animated:true)
      vc.delegate = self
      vc.step_edit = stepForPath(self.path)
      vc.group = groupForPath(self.path)
    end
  end


  ############################################################################
  # Table View delegation

  def numberOfSectionsInTableView(tableView)
    @items.count
  end

  def tableView(tableView, numberOfRowsInSection:section)
    @items[section][:steps].count
  end

  def tableView(tableView, viewForHeaderInSection:section)
    header = tableView.dequeueReusableCellWithIdentifier(BrewDayGroupCell.name)
    item = @items[section][:group]
    header.populate(item)
    header.info.tag = section

    view = UIView.alloc.initWithFrame(header.frame)
    view.addSubview(header)
    view  
  end 
  
  def tableView(tableView, heightForRowAtIndexPath:path)
    50
  end
  
  def tableView(tableView, heightForHeaderInSection:section)
    34
  end
  
  def tableView(tableView, cellForRowAtIndexPath:path)
    item = stepForPath(path)
    cell = tableView.dequeueReusableCellWithIdentifier(BrewDayStepCell.name)
    cell.populate(item)

    cell
  end

  def tableView(tableView, commitEditingStyle:editing_style, forRowAtIndexPath:index_path)
    if editing_style == UITableViewCellEditingStyleDelete
      table.beginUpdates
      steps = stepsForPath(index_path)
      steps[index_path.row].destroy
      steps.delete_at(index_path.row)
      reorderSteps(steps)    
      self.table.deleteRowsAtIndexPaths([index_path], withRowAnimation:UITableViewRowAnimationAutomatic)
      table.endUpdates
    end
  end

  def tableView(tableView, targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath, toProposedIndexPath:proposedDestinationIndexPath)
    sourceIndexPath.section == proposedDestinationIndexPath.section ? proposedDestinationIndexPath : sourceIndexPath
  end

  def tableView(tableView, moveRowAtIndexPath:from_index_path, toIndexPath:to_index_path)
    if from_index_path.row != to_index_path.row # make sure it actually moved
      steps = stepsForPath(from_index_path)
      step = steps[from_index_path.row]
      steps.delete_at(from_index_path.row)
      steps.insert(to_index_path.row, step)
      reorderSteps(steps)
    end
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
    bdv = self.storyboard.instantiateViewControllerWithIdentifier('BrewDayAddGroupView')
    bdv.delegate = self
    bdv.group_edit = nil
    self.presentModalViewController(bdv, animated:true)
  end

  def infoGroupPressed(sender)
    @selectedSection = sender.tag
    sheet = UIActionSheet.alloc.initWithTitle(nil,
                                              delegate:self,
                                              cancelButtonTitle:"Cancel",
                                              destructiveButtonTitle:"Delete",
                                              otherButtonTitles:"Edit", "Add Step", "Move Up", "Move Down", nil)
    sheet.showInView(self.view)
  end

  def actionSheet(actionSheet, didDismissWithButtonIndex:buttonIndex)
    case buttonIndex
    when 0 # Delete
      deleteGroup(@selectedSection)
    when 1 # Edit
      vc = self.storyboard.instantiateViewControllerWithIdentifier('BrewDayAddGroupView')
      vc.delegate = self
      vc.group_edit = @items[@selectedSection][:group]
      vc.steps_edit = @items[@selectedSection][:steps]
      self.presentModalViewController(vc, animated:true)
    when 2 # Add Step
      bdv = self.storyboard.instantiateViewControllerWithIdentifier('BrewDayAddStepView')
      bdv.delegate = self
      bdv.step_edit = nil
      bdv.group = @items[@selectedSection][:group]
      self.presentModalViewController(bdv, animated:true)
    when 3 # Move Up
      moveGroupUp(@selectedSection) unless @selectedSection.nil?
    when 4 # Move Down
      moveGroupDown(@selectedSection) unless @selectedSection.nil?
    end
  end


  ############################################################################
  # Delegate interface

  def groupPosition
    @items.count
  end

  def addGroupDone(brew_group)
    updateItems
    self.table.beginUpdates
    self.table.insertSections(NSIndexSet.indexSetWithIndex(brew_group.position), withRowAnimation:UITableViewRowAnimationAutomatic)
    self.table.endUpdates
  end

  def editGroupDone(brew_group)
    updateItems
    self.table.reloadData
  end

  def addStepDone(brew_step, brew_group)
    updateItems
    paths = [NSIndexPath.indexPathForRow(brew_step.position, inSection:brew_group.position)]
    self.table.beginUpdates
    self.table.insertRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimationAutomatic)
    self.table.endUpdates
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


  ############################################################################
  # Internal

  private

    def updateItems
      # @@@@@ We shouldn't have to sort Core Data like this!  There must
      # @@@@@ be a better way, but I can't figure it out right now.
      @items = []
      brew.groups.each do |group|
        steps = []
        group.steps.each do |s|
          steps << s
        end
        steps.sort! { |a,b| a.position <=> b.position }
        @items << { :group => group, :steps => steps }
      end
      @items.sort! { |a,b| a[:group].position <=> b[:group].position }
    end

    def groupForPath(path)
      @items[path.section][:group]
    end

    def stepForPath(path)
      @items[path.section][:steps][path.row]
    end

    def stepsForPath(path)
      @items[path.section][:steps]
    end

    def reorderSteps(steps)
      steps.each_with_index do |step, i|
        step.position = i
        step.save!
      end
      updateItems
    end

    def reorderGroups(groups)
      groups.each_with_index do |group, i|
        group[:group].position = i
        group[:group].save!
      end
      updateItems
      self.table.reloadData
    end

    def deleteGroup(section)
      group = @items[section][:group]
      group.destroy
      @items.delete_at(section)
      reorderGroups(@items)    
    end

    def moveGroupUp(section)
      if section != 0 # not the top, so move it
        switch = @items.slice!(section-1..section)
        switch.rotate!
        @items.insert(section-1, switch).flatten!
        reorderGroups(@items)
      end
    end

    def moveGroupDown(section)
      if section != @items.count - 1 # not the bottom, so move it
        switch = @items.slice!(section..section+1)
        switch.rotate!
        @items.insert(section, switch).flatten!
        reorderGroups(@items)
      end
    end

end