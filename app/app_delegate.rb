class AppDelegate

  include MotionDataWrapper::Delegate
  
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    #TestFlight.takeOff("acde9e93-d73e-44b5-86e7-18c2070ddc29")
    application.setStatusBarStyle(UIStatusBarStyleLightContent)
    true
  end
  
  # Cannot define these using attr_accessor :window. 
  def window
    @window
  end
  
  def setWindow(window)
    @window = window
  end
end
