var Contact = function () {
    return {
        //Map
        initMap: function () {
			var map;
			$(document).ready(function(){
			  map = new GMaps({
				div: '#map',
				lat: 56.0084763,
				lng: 11.985019
			  });
			   var marker = map.addMarker({
		            lat: 56.008476,
					lng: 11.985019,
		            title: 'Loop, Inc.'
		        });
			});
        }

    };
}();