# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")

begin
  require 'motion/project/template/ios'
  require 'bundler'
  require 'bubble-wrap/reactor'
  #require 'motion-cocoapods'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'BrewDay'
  app.info_plist['UIMainStoryboardFile'] = 'MainStoryboard'
  #app.identifier = 'com.ironsafe.test'
  app.interface_orientations = [:portrait]
  #app.icons = ['Icon.png', 'Icon@2x.png']
  app.prerendered_icon = false

  app.frameworks += ['QuartzCore', 'CoreData']

  app.info_plist['UIViewControllerBasedStatusBarAppearance'] = false

  # !!!!! TESTING
  #app.archs['iPhoneOS'] << 'arm64'
  #app.archs['iPhoneSimulator'] << 'x86_64'

  #app.testflight.sdk = 'vendor/TestFlightSDK2.0.0'
  #app.testflight.api_token = '9056f33ee65d4b8d11ee48af3f46bd5a_MTE1NDYxMzIwMTMtMDctMDggMDk6NDk6MzcuNTM1MDQ0'
  #app.testflight.team_token = '6534a7e693c9b00b660e39028c0c070b_MjQ1NzI2MjAxMy0wNy0wOCAwOTo1NDoxNi44Njg1NDU'

  app.pods do
    #pod 'ECSlidingViewController', podspec: '~/.cocoapods/repos/master/ECSlidingViewController/1.3.2/ECSlidingViewController.podspec'
    pod 'ECSlidingViewController', podspec: 'https://raw.github.com/CocoaPods/Specs/master/ECSlidingViewController/1.3.2/ECSlidingViewController.podspec'
    pod 'SWTableViewCell', podspec: 'https://raw.github.com/CocoaPods/Specs/master/SWTableViewCell/0.2.4/SWTableViewCell.podspec'    
  end

  app.development do
    # This entitlement is required during development but must not be used for release.
    app.entitlements['get-task-allow'] = true
    #app.provisioning_profile = '/Users/philcallister/Library/MobileDevice/Provisioning Profiles/4F1A8D2A-F2B8-420C-A749-47D708C54B56.mobileprovision'
  end

  app.release do
    # This entitlement is required during development but must not be used for release.
    app.entitlements['get-task-allow'] = false

    # AD-HOC
    #app.codesign_certificate = 'iPhone Distribution: Crosspoint Consulting LLC (Z2GD62V75U)'
    #app.provisioning_profile = '/Users/philcallister/Library/MobileDevice/Provisioning Profiles/7BD6D36B-290B-4EF0-9499-CAF5E2D712FC.mobileprovision'
  end

end

# Track and specify files and their mutual dependencies within the :motion 
# Bundler group
#MotionBundler.setup
