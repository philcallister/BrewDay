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
    self.table.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
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
    when 'BrewDayStepsEditGroupSegue'
      self.path = table.indexPathForSelectedRow
      self.table.deselectRowAtIndexPath(self.path, animated:true)
      vc.delegate = self
      vc.group_edit = @items[self.path.row]
    when 'BrewDayStepsEditStepSegue'
      self.path = table.indexPathForSelectedRow
      table.deselectRowAtIndexPath(self.path, animated:true)
      vc.delegate = self
      vc.step_edit = @items[self.path.row]
    end
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

  def tableView(tableView, canEditRowAtIndexPath:indexPath)
    return indexPath.row != 0
  end

  def tableView(tableView, canMoveRowAtIndexPath:index_path)
    item = @items[index_path.row]
    return item.kind_of? StepTemplate
  end

  def tableView(tableView, targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath, toProposedIndexPath:proposedDestinationIndexPath)
    source = @items[sourceIndexPath.row]
    if source.kind_of? StepTemplate
      return proposeMoveStep(sourceIndexPath, proposedDestinationIndexPath)
    # elsif source.kind_of? GroupTemplate
    #   return proposeMoveGroup(sourceIndexPath, proposedDestinationIndexPath)
    end
    return sourceIndexPath
  end

  def tableView(tableView, moveRowAtIndexPath:from_index_path, toIndexPath:to_index_path)
    if from_index_path.row != to_index_path.row # make sure it actually moved
      item = @items[from_index_path.row]
      @items.delete_at(from_index_path.row)
      @items.insert(to_index_path.row, item)
      reorder(@items)
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
    buttonPosition = sender.convertPoint(CGPointZero, toView:self.table)
    @selectedIndexPath = self.table.indexPathForRowAtPoint(buttonPosition)
    unless @selectedIndexPath.nil?
      sheet = UIActionSheet.alloc.initWithTitle(nil,
                                                delegate:self,
                                                cancelButtonTitle:"Cancel",
                                                destructiveButtonTitle:nil,
                                                otherButtonTitles:"Add Step", "Move Up", "Move Down", nil)
      sheet.showInView(self.view)
   end
  end

  def actionSheet(actionSheet, didDismissWithButtonIndex:buttonIndex)
    case buttonIndex
    when 0 # Add Step
      bdv = self.storyboard.instantiateViewControllerWithIdentifier('BrewDayAddStepView')
      bdv.delegate = self
      bdv.step_edit = nil
      bdv.group = addGroup
      self.presentModalViewController(bdv, animated:true)
    when 1 # Move Up
      moveGroupUp(@selectedIndexPath.row) unless @selectedIndexPath.nil?
    when 2 # Move Down
      moveGroupDown(@selectedIndexPath.row) unless @selectedIndexPath.nil?
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
    self.table.beginUpdates
    self.table.insertRowsAtIndexPaths(paths, withRowAnimation:UITableViewRowAnimationAutomatic)
    self.table.endUpdates
  end

  def editGroupDone(brew_group)
    updateItems

    cell = table.cellForRowAtIndexPath(self.path)
    cell.populate(brew_group)
  end

  def addStepDone(brew_step)
    updateItems

    paths = [NSIndexPath.indexPathForRow(brew_step.position, inSection:0)]
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
      @items = []
      brew.items.each { |item| @items.push item }

      # @@@@@ F*CK!  I shouldn't have to sort this!  There must
      # @@@@@ be a better way, but I can't find it right now.
      @items.sort! { |a,b| a.position <=> b.position }
    end

    def reorder(items)
      items.each_with_index do |item, i|
        item.position = i
        item.save!
      end

      updateItems
    end

    def addGroup()
      @items.reverse_each do |item|
        return item if item.kind_of? GroupTemplate
      end
      return nil
    end

    def thisGroup(item, index)
      { :item => item, :index => index }
    end

    def topGroup(items, index)
      items[0..index].reverse.each_with_index do |i, idx|
        return { :item => i, :index => index - idx } if i.kind_of? GroupTemplate
      end
      return nil
    end

    def bottomGroup(items, index)
      items[index..-1].each_with_index do |i, idx|
        return { :item => i, :index => index + idx } if i.kind_of? GroupTemplate
      end
      return nil
    end

    def lastStep(items, index)
      last_step_item = nil
      last_step_idx = 0
      items[index..-1].each_with_index do |i, idx|
        break if !i.kind_of? StepTemplate
        last_step_item = i
        last_step_index = idx
      end
      return last_step_item.nil? ? nil : { :item => last_step_item, :index => index + last_step_idx }
    end

    def proposeMoveStep(sourceIndexPath, proposedDestinationIndexPath)
      # only allow moves within same group
      source = @items[sourceIndexPath.row]
      proposed = @items[proposedDestinationIndexPath.row]
      top = topGroup(@items, source.position)
      topPosition = (top.nil?) ? -1 : top[:item].position
      bottom = bottomGroup(@items, source.position)
      bottomPosition = (bottom.nil?) ? @items.count : bottom[:item].position
      if (proposed.position <= topPosition) || (proposed.position >= bottomPosition)
        return sourceIndexPath
      end
      return proposedDestinationIndexPath
    end

    # def proposeMoveGroup(sourceIndexPath, proposedDestinationIndexPath)
    #   # only allow move to another group
    #   proposed = @items[proposedDestinationIndexPath.row]
    #   if proposed.kind_of? GroupTemplate
    #     return proposedDestinationIndexPath 
    #   end
    #   return sourceIndexPath
    # end

    def moveGroupUp(row)
      bot_group = thisGroup(@items[row], row)
      return if bot_group[:item] == @items.first
      top_group = topGroup(@items, bot_group[:item].position-1)
      if bot_group[:item].kind_of? GroupTemplate
        # find the last step of the bottom group
        last_step = lastStep(@items, bot_group[:item].position+1)
        last_step = bot_group if last_step.nil?
        # remove these 2 groups, including their steps, from the main items.
        # Once we've removed them, we'll rotate on the bottom group
        # to reverse their positions and then reinsert into the main items.
        move_items = @items.slice!(top_group[:item].position..last_step[:item].position)
        rotate_group = bottomGroup(move_items, 1) # index after top group
        move_items.rotate!(rotate_group[:index])
        @items.insert(top_group[:item].position, move_items).flatten!
        # reset the table
        reorder(@items)
        self.table.reloadData
      end
    end

    def moveGroupDown(row)
      top_group = thisGroup(@items[row], row)
      bot_group = bottomGroup(@items, top_group[:item].position+1)
      return if top_group[:item] == @items.last || bot_group.nil? # this is last group
      if top_group[:item].kind_of? GroupTemplate
        # find the last step of the bottom group
        last_step = lastStep(@items, bot_group[:item].position+1)
        last_step = bot_group if last_step.nil?
        # remove these 2 groups, including their steps, from the main items.
        # Once we've removed them, we'll rotate on the bottom group
        # to reverse their positions and then reinsert into the main items.
        move_items = @items.slice!(top_group[:item].position..last_step[:item].position)
        rotate_group = bottomGroup(move_items, 1) # index after top group
        move_items.rotate!(rotate_group[:index])
        @items.insert(top_group[:item].position, move_items).flatten!
        # reset the table
        reorder(@items)
        self.table.reloadData
      end
    end

end