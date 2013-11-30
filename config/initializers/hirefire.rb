HireFire::Resource.configure do |config|
  config.dyno(:worker) do
  	#Mapper must be explicit given which the documentation does mention - https://github.com/justincampbell/hirefire-resource/commit/b7c3a37b84a276f734859b73a2a72ce72958484f
    HireFire::Macro::Delayed::Job.queue(mapper: :active_record)
  end
end