class AppDelegate

  include MotionDataWrapper::Delegate

  attr_accessor :timer
  
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
    puts "!!!!! applicationDidBecomeActive(): #{self.timer}"
    seconds = (Time.now - @time).round if self.timer
    self.timer.elapsed(seconds) if self.timer
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
