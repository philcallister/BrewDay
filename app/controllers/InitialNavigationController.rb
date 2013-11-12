class InitialNavigationController < UINavigationController

  extend IB

  def viewDidLoad
    super
  end

  def viewWillAppear(animated)
    super

    # Add a shadow to the top view so it looks like it is on top of the others
    self.view.layer.shadowOpacity = 0.75
    self.view.layer.shadowRadius = 10.0
    self.view.layer.shadowColor = UIColor.blackColor.CGColor

    # Tell it which view should be created under left
    unless (self.slidingViewController.underLeftViewController.is_a? MenuViewController)
      self.slidingViewController.underLeftViewController = self.storyboard.instantiateViewControllerWithIdentifier('MenuView')
      self.slidingViewController.anchorRightPeekAmount = 55
    end

    # Add the pan gesture to allow sliding
    # @@@@@ In order to turn this on, we need to be able to turn it off
    # as soon as the user needs to reorder items on other view controller
    #self.view.addGestureRecognizer(self.slidingViewController.panGesture)
  end

end