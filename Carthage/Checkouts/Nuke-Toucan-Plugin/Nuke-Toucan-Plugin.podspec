Pod::Spec.new do |s|
    s.name             = 'Nuke-Toucan-Plugin'
    s.version          = '0.3'
    s.summary          = 'Toucan plugin for Nuke - image loading and caching framework'

    s.homepage         = 'https://github.com/kean/Nuke-Toucan-Plugin'
    s.license          = 'MIT'
    s.author           = 'Alexander Grebenyuk'
    s.source           = { :git => 'https://github.com/kean/Nuke-Toucan-Plugin.git', :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/a_grebenyuk'

    s.ios.deployment_target = '9.0'
    s.tvos.deployment_target = '9.0'

    s.module_name      = "NukeToucanPlugin"

    s.dependency 'Nuke', '~> 5.0'
    s.dependency 'Toucan', '>= 0.6'

    s.source_files  = 'Sources/**/*'
end
