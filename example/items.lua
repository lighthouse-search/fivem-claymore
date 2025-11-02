return {
	['claymore'] = {
		label = 'Claymore',
		weight = 5200,
		degrade = 86400,
		-- duration = 1800, // i don't think 'duration' exists
		description = 'Motion-activated explosive.',
		client = {
			image = 'Claymore.png',
			prop = 'Claymore',
			usetime = 2500,
			export = 'hades_claymore.place_self'
		},
		server = {
			export = 'hades_claymore.place_self'
		},
		buttons = {
			{
				label = 'Place',
				action = function(slot)
					exports['hades_claymore']:place()
				end
			},
		},
		consume = 0.3
	},
}