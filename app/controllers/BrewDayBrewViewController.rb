class BrewDayBrewViewController < UIViewController

  extend IB

  attr_accessor :delegate, :brew

  @@timer = nil
  @@seconds = 0
  @@timer_running = false

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

    puts "!!!!! viewDidLoad()"

    updateItems
    self.navigationItem.rightBarButtonItems = [self.editButtonItem]
  end

  def viewWillAppear(animated)
    puts "!!!!! viewWillAppear()"

    BrewDayBrewViewController::attachToTimer self.elapsed_time

    self.name.text = self.brew.name
    self.info.text = self.brew.info
    self.brew_style.text = self.brew.brew_style.to_s
    self.brew_style_view.layer.cornerRadius = 7
    #self.elapsed_time_view.layer.cornerRadius = 7

    super
  end

  def viewWillDisappear(animated)
    puts "!!!!! viewWillDisappear()"
    puts "!!!!! delegate: #{App.delegate}"

    super
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

    # !!!!! Baloney here...
    self.brew.finished = Brew::YES
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
    @@timer_running = !@@timer_running
    if @@timer_running
      @@seconds = 0
      BrewDayBrewViewController::startTimer self.elapsed_time
    else
      BrewDayBrewViewController::cancelTimer
    end
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

    def stepForPath(path)
      @items[path.section][:steps][path.row]
    end

    # !!!!!
    def self.attachToTimer(label)
      @@label = label
    end

    # !!!!!
    def self.startTimer(label)
      cancelTimer
      attachToTimer label
      @@timer = EM.add_periodic_timer 1.0 do
        @@seconds = @@seconds + 1
        formatted = Time.at(@@seconds).utc.strftime("%H:%M:%S")
        @@label.text = formatted
        puts "!!!!! #{formatted}"
      end
      App.delegate.timer = @@timer
      App.delegate.brew_controller = self
    end

    # !!!!!
    def self.cancelTimer
      EM.cancel_timer(@@timer) if @@timer
      @@timer = nil
      App.delegate.timer = nil
      App.delegate.brew_controller = nil
    end


    ############################################################################
    # Delegate interface

    def self.elapsedSeconds(seconds)
      puts "!!!!! elapsedSeconds() : #{@@seconds} + #{seconds}"
      @@seconds += seconds
    end


end