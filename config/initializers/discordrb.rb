require 'discordrb'

class Time
	def prime?
		hour >= 18
	end
end

if ENV["DISCORD_SERVER"] != nil && ENV["DISCORD_CLIENT"] != nil && ENV["DISCORD_TOKEN"] != nil

	$bot = Discordrb::Commands::CommandBot.new token: ENV["DISCORD_TOKEN"], client_id: ENV["DISCORD_CLIENT"]
	# $bot.message(with_text: 'Ping!') do |event|
	# 	user = event.user
	# 	member = user.on(ENV["DISCORD_SERVER"])
	# 	server = member.server
	# 	Rails.logger.info "--------------------------"
	# 	Rails.logger.info member.server.roles.to_s
	# 	Rails.logger.info "--------------------------"
	# 	role = member.server.roles.find {|role| role.name == 'Member'}
	# 	server.members.each do |user|
	# 		Rails.logger.info user.username.to_s
	# 	end

	# 	member.add_role(role)
	# 	event.respond 'Pong! Hello ' + user.name.to_s
	# end

	# $bot.message(with_text: 'Pong!') do |event|
	# 	user = event.user
	# 	member = user.on(ENV["DISCORD_SERVER"])
	# 	# server = member.server
	# 	# Rails.logger.info "--------------------------"
	# 	# Rails.logger.info member.server.roles.to_s
	# 	# Rails.logger.info "--------------------------"
	# 	role = member.server.roles.find {|role| role.name == 'Member'}
	# 	Rails.logger.info role.id.to_s
	# 	member.remove_role(role)
	# 	event.respond 'Ping! Hello ' + user.name.to_s
	# end


	$bot.mention() do |event|
		note = event.message.to_s.downcase.gsub!(/\s+/, '')
		Rails.logger.info "Discord Mention: " + note.to_s
		if note.to_s.blank? or note.include? "help" or note.include? "list" or note.include? "commands"
			event.respond "

			Bot Command List: 

			Help = This is redundant... you just asked for help.
			Time = Tells you the time of all the major time zones (* marks current prime times)
			Events = Gets todays events and PMs their times.

			"
		else

			if note.include? "event"
				Time.zone = 'UTC'
				Rails.logger.info "Channel " + event.author.id.to_s
				begin
				return_check = 0
				user = User.where('discord_user_id' => event.author.id)
				Rails.logger.info "Valid? " + user[0].valid_api.to_s
				if user[0].valid_api == false
					Rails.logger.info "Invalid user, no event info posted"
					return_check = 1 
				end
				rescue
					Rails.logger.info "Unsubscribed user, no event info posted"
					return_check = 1
				end
				if return_check == 0
									Rails.logger.info "Discord Mention: Events GET"
				timers = Timesheet.where("event_time between ? and ?", Time.zone.now.beginning_of_day, Time.zone.now.tomorrow)
				message = 'Todays Events
Current Time (EvE / UTC) ' + Time.zone.now.to_s
				timers.each do |target|
					message = message + "
--==============================--
" + target.event.to_s + "
Event Time " + target.event_time.to_s + "
Target: " + target.event_type.to_s + "

Info:
" + target.notes + "

--==============================--
"
				end
				event.author.pm(message)
				end

			end

			if note.include? "time"

				est = ActiveSupport::TimeZone.new("Eastern Time (US & Canada)")
				est_prime = Time.now.in_time_zone(est).prime? ? '*' : ''
				# event.respond "EST" + prime + " - " + Time.now.in_time_zone(zone).to_s

				pst = ActiveSupport::TimeZone.new("Pacific Time (US & Canada)")
				pst_prime = Time.now.in_time_zone(pst).prime? ? '*' : ''
				# event.respond "PST" + prime + " - " + Time.now.in_time_zone(zone).to_s

				utc = ActiveSupport::TimeZone.new("Etc/UTC")
				utc_prime = Time.now.in_time_zone(utc).prime? ? '*' : ''
				# event.respond "UTC/EvE" + prime + " - " + Time.now.in_time_zone(zone).to_s

				cst = ActiveSupport::TimeZone.new("Asia/Shanghai")
				cst_prime = Time.now.in_time_zone(cst).prime? ? '*' : ''

				aest = ActiveSupport::TimeZone.new("Australia/Sydney")
				aest_prime = Time.now.in_time_zone(aest).prime? ? '*' : ''
				# event.respond "AEST" + prime + " - " + Time.now.in_time_zone(zone).to_s

				msk = ActiveSupport::TimeZone.new("Europe/Moscow")
				msk_prime = Time.now.in_time_zone(msk).prime? ? '*' : ''
				# event.respond "MSK" + prime + " - " + Time.now.in_time_zone(zone).to_s
				event.respond "
				Major Time Zones

				PST" + pst_prime + " - " + Time.now.in_time_zone(pst).to_s + "
				EST" + est_prime + " - " + Time.now.in_time_zone(est).to_s + "
				UTC" + utc_prime + " - " + Time.now.in_time_zone(utc).to_s + " (EvE Server time)
				MSK" + msk_prime + " - " + Time.now.in_time_zone(msk).to_s + "
				CST" + cst_prime + " - " + Time.now.in_time_zone(cst).to_s + "
				AEST" + aest_prime + " - " + Time.now.in_time_zone(aest).to_s + "
				(* marks current prime times)"
				
			end

			if note.include? "openthepodbaydoor"
				event.respond "I'm sorry, Dave."
				event.respond "I'm afraid I can't do that."

			end

			if note.include? "speak"
				text = ["Woof!", "Bark!", "Cluck!", "Woof", "Greetings Human", "Beep Boop", "Bark", "Woof!", "Shut up you Goomba faced idiot or i'll kill you with my nose", "Woof!", "Bark!", "Her name is Caroline", "I dont hate you", "Goodbye now", "Dont get angry, make lemonaid", "This is all your fault", "R2-D2 where are you?", "But Turrner, im just trying to return these hedge clippers... into your face!", "Woof!", "Bark!"]
				event.respond text[rand(0...text.length)].to_s
			end

			if note.include? "wholivesinapineappleunderthesea"
				event.respond "Spongebob Squarepants!!!"
			end

			if note.include? "cookie"
				Metric_create(event, note)
			end
		end
	end

	# $bot.message(contains: 'cookie') do |event|
	# 	note = event.message.to_s.downcase.gsub!(/\s+/, '')
	# 	Metric_create(event, note)
	# end
	

	$bot.member_update do |event|
		Rails.logger.info "New User Updated"
	end

	$bot.member_join do |event|
		Rails.logger.info "New User Joined"
	end

	$bot.ready do |event|
		$bot.game = "Beta version 0.27"
		# $bot.send_message(307641304425168896, 'Auth-bot is online!', tts = false, embed = nil)
	end

	$bot.run :async
end

def Metric_create (event, note)
	Rails.logger.info "Metrics Create"
	note_unfiltred = event.message.to_s
	event.respond "Gib cookie"
	@author = User.where('discord_user_id' => event.author.id)
	Rails.logger.info "Discord Mention: Cookie Metric 1: " + @author[0].email.to_s + " | " + @author[0].discord_user_id.to_s
	@user_ids = note.scan(/(\d{18})/)
	@author_id = @author[0].discord_user_id
				# @users_parsed
				@note = note_unfiltred.scan(/"([^"]*)"/)
				Rails.logger.info @user_ids.to_s
				@users_filtred = []
				Rails.logger.info "==============================="
				
				@user_ids.each do |x|
					check = false
					if x[0].to_s == @author_id.to_s || x[0].to_s == ENV["DISCORD_CLIENT"].to_s
						check = true
					else 
						@users_filtred.push(x[0])
					end
					Rails.logger.info "Mention Check: " + x[0].to_s + " | " + ENV["DISCORD_CLIENT"].to_s + " : " + @author_id.to_s + " | " + check.to_s
				end
				@users_filtred = @users_filtred.uniq

				@player_names = note_unfiltred.scan(/(\(.*?\))/)
				@player_names = @player_names.to_s.gsub(/[()]/, "")
				@player_names = @player_names.split(',')
				@player_name_strings = []
				@player_names.each do |x|
					x = x.tr('[]"', '')
					if x[0] == " "
						x.slice!(0)
					end
					Rails.logger.info "PM Check: " + x.to_s
					@player_name_strings.push(x.to_s)
				end

				Rails.logger.info "==============================="
				Rails.logger.info "Users: " + @users_filtred.to_s + " " + @player_name_strings.to_s + " | Bot: " + ENV["DISCORD_CLIENT"].to_s + " | " + @note[0].to_s
				Rails.logger.info "Mention: " + @users_filtred.length.to_s + " PM: " + @player_name_strings.length.to_s

				@target_users = []

				@users_filtred.each do |x|
					@mentioned_users = User.where('discord_user_id' => x)
					if @mentioned_users.empty? == false
						@target_users.push(@mentioned_users)
					end
				end

				@player_name_strings.each do |x|
					@pm_users = User.where('primary_character_name' => x)
					if @pm_users.empty? == false
						@target_users.push(@pm_users)
					end
				end


				Rails.logger.info "Target_users: " + @target_users.to_s

end
