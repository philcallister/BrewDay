class AppDelegate

  include MotionDataWrapper::Delegate

  attr_accessor :brew_controller, :timer
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    #TestFlight.takeOff("acde9e93-d73e-44b5-86e7-18c2070ddc29")
    application.setStatusBarStyle(UIStatusBarStyleLightContent)
    true
  end

  def applicationWillResignActive(application)
    puts "!!!!! applicationWillResignActive()"
  end

  def applicationWillEnterForeground(application)
    puts "!!!!! applicationWillEnterForeground()"
  end

  def applicationDidEnterBackground(application)
    @time = Time.now if self.timer
    puts "!!!!! applicationDidEnterBackground(): #{@time}"
  end

  def applicationDidBecomeActive(application)
    puts "!!!!! applicationDidBecomeActive(): #{self.brew_controller}"
    seconds = Time.now - @time if self.timer
    self.brew_controller.elapsedSeconds(seconds) if self.brew_controller && self.timer
  end
  
  def applicationWillTerminate(application)
    puts "!!!!! applicationWillTerminate()"
  end

  # Cannot define these using attr_accessor :window. 
  def window
    @window
  end
  
  def setWindow(window)
    @window = window
  end

  # manage timers


end
