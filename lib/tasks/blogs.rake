#encoding: utf-8
namespace :blogs do
 
  desc "Retrieve campaign status from server"
  task :get_feed => :environment do
  	puts "Preparing to load feed items from WordPress blog..."
  	FeedEntry.update_from_feed("http://blog.clubnovus.dk/?feed=rss2")
  	puts "Preparing to load feed items from WordPress blog...done"
  end#End task

end#End namespace