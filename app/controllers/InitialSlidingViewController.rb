class InitialSlidingViewController < ECSlidingViewController

  def viewDidLoad
    super

    self.topViewController = self.storyboard.instantiateViewControllerWithIdentifier('InitialNavigation')
  end

end