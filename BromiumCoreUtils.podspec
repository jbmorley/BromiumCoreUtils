Pod::Spec.new do |s|

  s.name         = "BromiumCoreUtils"
  s.version      = "1.0.0"
  s.summary      = "Core Objective-C/Cocoa utilities by Bromium Inc."
  s.homepage     = "https://github.com/jbmorley/BromiumCoreUtils"
  s.license      = { :type => 'BSD', :file => 'LICENSE' }
  s.author       = { "Jason Barrie Morley" => "jason.morley@inseven.co.uk" }
  s.source       = { :git => "https://github.com/jbmorley/BromiumCoreUtils.git", :tag => "1.0.0" }

  s.source_files = 'BromiumCoreUtils/BRUAsserts.{h,m}', 'BromiumCoreUtils/BRUInternalMaybeDDLog.{h,m}', 'BromiumCoreUtils/BRUBaseDefines.{h,m}', 'BromiumCoreUtils/BRUDispatchUtils.{h,m}', 'BromiumCoreUtils/BRUDeferred.{h,m}', 'BromiumCoreUtils/BRUConcurrentBox.{h,m}', 'BromiumCoreUtils/BRUEitherErrorOrSuccess.{h,m}'

  s.requires_arc = true

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.watchos.deployment_target = '3.0'

end
