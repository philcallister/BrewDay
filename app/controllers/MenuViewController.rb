class MenuViewController < UIViewController

  # outlet
  attr_accessor :table_view

  def viewDidLoad
    super
    @first_appearance = true

    @menu = [{ :label => 'Create', :func => :display_view, :params => { :id => 'InitialNavigation'}, :deselect => false },
              { :label => 'Brew', :func => :display_view, :params => { :id => 'InitialNavigation'}, :deselect => false },
              { :label => 'Log', :func => :display_view, :params => { :id => 'InitialNavigation'}, :deselect => false },
              { :label => 'Settings', :func => :display_view, :params => { :id => 'InitialNavigation'}, :deselect => false }]

    #self.slidingViewController.setAnchorRightRevealAmount(280.0)
    self.slidingViewController.underLeftWidthLayout = ECFullWidth
  end

  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    @menu.count
  end
  
  def tableView(tableView, cellForRowAtIndexPath:path)
    item = @menu[path.row][:label]
    cell = tableView.dequeueReusableCellWithIdentifier(MenuCell.name)
    cell.menu_label.text = item
    if @first_appearance
      @first_appearance = false
      tableView.selectRowAtIndexPath(path, animated:false, scrollPosition:UITableViewScrollPositionTop)
    end
    
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:path)
    item = @menu[path.row]
    if self.respond_to?(item[:func])
      if item[:params]
        self.send(item[:func], item[:params])
      else
        self.send(item[:func])
      end
    end
    tableView.deselectRowAtIndexPath(path, animated:true) if item[:deselect]
  end

  def display_view(params)
    newTopViewController = self.storyboard.instantiateViewControllerWithIdentifier(params[:id])
    self.slidingViewController.anchorTopViewOffScreenTo(ECRight, animations:nil, onComplete:lambda do
      frame = self.slidingViewController.topViewController.view.frame
      self.slidingViewController.topViewController = newTopViewController
      self.slidingViewController.topViewController.view.frame = frame
      self.slidingViewController.resetTopView
    end)
  end

end