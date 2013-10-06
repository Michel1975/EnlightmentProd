Cloudinary.config do |config| 
	config.cloud_name = ENV["IMAGE_CLOUD_NAME"]
  	config.api_key = ENV["IMAGE_API_KEY"]
  	config.api_secret = ENV["IMAGE_API_SECRET"]
  	config.enhance_image_tag = ENV["IMAGE_ENHANCE_IMAGE_TAG"]
  	config.static_image_support = ENV["IMAGE_STATIC_IMAGE_SUPPORT"]
end