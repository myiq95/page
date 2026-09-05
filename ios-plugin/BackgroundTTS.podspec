Pod::Spec.new do |s|
  s.name             = 'BackgroundTTS'
  s.version          = '1.0.0'
  s.summary          = 'Background TTS for PAGES'
  s.license          = 'MIT'
  s.homepage         = 'https://pages.reader'
  s.author           = 'PAGES'
  s.source           = { :path => '.' }
  s.source_files     = 'BackgroundTTS/**/*.{swift,h,m}'
  s.ios.deployment_target = '13.0'
  s.dependency 'Capacitor'
  s.swift_version = '5.1'
end