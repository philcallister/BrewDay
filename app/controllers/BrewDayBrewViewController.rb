class BrewDayBrewViewController < UIViewController

  extend IB

  attr_accessor :delegate, :brew, :path

  @@timer = BrewTimer::Timer.new

  # Outlets
  outlet :name, UILabel
  outlet :info, UILabel
  outlet :brew_style_view, UIView
  outlet :brew_style, UILabel
  outlet :brew_info, UIButton
  outlet :table, UITableView
  outlet :elapsed_time_view, UIView
  outlet :elapsed_time, UILabel

  def viewDidLoad
    super

    puts "!!!!! viewDidLoad(#{self})"

    updateItems
    self.navigationItem.rightBarButtonItems = [self.editButtonItem]
  end

  def viewWillAppear(animated)
    puts "!!!!! viewWillAppear(#{self})"

    #@@timer.attachToTimer self.elapsed_time
    @@timer.add(:label) do |seconds|
      puts "!!!!! LABEL: #{seconds}"
      formatted = Time.at(seconds).utc.strftime("%H:%M:%S")
      self.elapsed_time.text = formatted
    end

    self.name.text = self.brew.name
    self.info.text = self.brew.info
    self.brew_style.text = self.brew.brew_style.to_s
    self.brew_style_view.layer.cornerRadius = 7
    #self.elapsed_time_view.layer.cornerRadius = 7

    super
  end

  def viewWillDisappear(animated)
    puts "!!!!! viewWillDisappear(#{self})"
    puts "!!!!! delegate: #{App.delegate}"

    super
  end

  def prepareForSegue(segue, sender:sender)
    vc = segue.destinationViewController

    case segue.identifier
    when 'BrewDayBrewNoteSegue'
      vc.delegate = self
      self.path = table.indexPathForSelectedRow
      self.table.deselectRowAtIndexPath(self.path, animated:true)
      vc.delegate = self
      vc.step = stepForPath(self.path)
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
    header.info.tag = section
    header.populate(item)
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

    # !!!!! Baloney here...
    self.brew.finished = Bool::YES
    self.brew.save!

    self.table.setEditing(is_editing, animated:is_animated)
    super
  end

  # We do this to avoid having separators after the last cell
  def tableView(tableView, heightForFooterInSection:section)
    return 0.01
  end


  ############################################################################
  # Actions

  def elapsedTimePressed
    @@timer.toggle
  end

  # def addPressed(sender) 
  #   cell = sender.superview.superview.superview
  #   item = @items[sender.tag][:group]
  #   item.marked = Bool::YES
  #   item.save!

  #   UIView.animateWithDuration(0.5,
  #     animations: lambda {
  #       cell.markGroup(item)
  #     }
  #   )
  # end

  def addPressed(sender)
    @selectedSection = sender.tag
    @selectedCell = sender.superview.superview.superview
    sheet = UIActionSheet.alloc.initWithTitle(nil,
                                              delegate:self,
                                              cancelButtonTitle:"Cancel",
                                              destructiveButtonTitle:"Delete",
                                              otherButtonTitles:"Start", "Edit", "Add Step", "Move Up", "Move Down", nil)
    sheet.showInView(self.view)
  end

  def actionSheet(actionSheet, didDismissWithButtonIndex:buttonIndex)
    case buttonIndex
    when 0 # Delete
      #deleteGroup(@selectedSection)
      puts "!!!!! Delete..."
    when 1 # Start
      item = @items[@selectedSection][:group]
      item.marked = Bool::YES
      item.save!

      UIView.animateWithDuration(0.5,
        animations: lambda {
          @selectedCell.markGroup(item)
        }
      )
      unless @@timer.timer_running
        elapsedTimePressed
      end
      @@timer.add(nil) do |seconds|
        puts "!!!!! GROUP TIMER: #{seconds}"
      end
    when 2 # Edit
      # vc = self.storyboard.instantiateViewControllerWithIdentifier('BrewDayAddGroupView')
      # vc.delegate = self
      # vc.group_edit = @items[@selectedSection][:group]
      # vc.steps_edit = @items[@selectedSection][:steps]
      # self.presentModalViewController(vc, animated:true)
      puts "!!!!! Edit..."
    when 3 # Add Step
      # bdv = self.storyboard.instantiateViewControllerWithIdentifier('BrewDayAddStepView')
      # bdv.delegate = self
      # bdv.step_edit = nil
      # bdv.group = @items[@selectedSection][:group]
      # self.presentModalViewController(bdv, animated:true)
      puts "!!!!! Add Step..."
    when 4 # Move Up
      # moveGroupUp(@selectedSection) unless @selectedSection.nil?
      puts "!!!!! Move Up..."
    when 5 # Move Down
      # moveGroupDown(@selectedSection) unless @selectedSection.nil?
      puts "!!!!! Move Down..."
    end
  end


  ############################################################################
  # Delegate interface

  def noteComplete(step)
    if step.finished == Bool::YES
      unless @@timer.timer_running
        elapsedTimePressed
      end
    end
      
    cell = self.table.cellForRowAtIndexPath(self.path)
    #cell.markStep(step)

    # Check to see if all steps have been completed.  If so, mark the group
    # as having been completed too.
    group = groupForPath(self.path)
    group.finished = (isGroupFinished(group)) ? Bool::YES : Bool::NO
    group.save!

    # @@@@@
    # We'll need the actual group CELL here so we can update its
    # background color.  Hmmmm...not sure
    self.table.reloadData
  end


  ############################################################################
  # Internal

  private

    def updateItems
      # @@@@@ We shouldn't have to sort Core Data like this!  There must
      # @@@@@ be a better way, but I can't figure it out right now.
      @items = []
      self.brew.groups.each do |group|
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

    def isGroupFinished(group)
      group.steps.each do |s|
        if s.finished == Bool::NO
          return false
        end
      end
      return true
    end

end