<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <title>Vehicle Simulator</title>
    
	<!-- Latest Bootstrap compiled and minified CSS -->
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap-theme.min.css">
	<asset:stylesheet href="main.css"/>
  </head>
  <body>
  	<div class="container logo">
		<g:img dir="images" file="ford_logo.png"/><label>Vehicle Simulator</label>
	</div>
	<nav class="navbar navbar-default">
		<div class="container">
			<div class="navbar-header">
				<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target=".navbar-collapse">
					<span class="sr-only">Toggle navigation</span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
				</button>
			</div>
			<div class="navbar-collapse collapse">
				<ul class="nav navbar-nav">
					<li class="active"><a href="#">Home</a></li>
				</ul>
				<div class="row" style="width:50%;float:right;">
					<div class="col-xs-8 alerts">
						<div class="alert alert-success" role="alert"><strong>Good Condition</strong> - Performing as expected.</div>
					</div>
					<div class="col-xs-2 buttons">
						<button type="button" class="btn btn-success" onclick="startTimer();">Start</button>
					</div>
					<div class="col-xs-2 buttons">
						<button type="button" class="btn btn-danger" onclick="stopTimer();">Stop</button>
				  		<g:if test="${flash.message}">
				  			<div class="message">${flash.message}</div>
				  		</g:if>
				  	</div>
				</div>
				
			</div><!--/.nav-collapse -->
		</div>
	</nav>  	
  	<div class="container">
		<div class="row main-content-row">
			<div class="col-xs-6 vehicle-info-container">
			    <div class="map-container">
				    <div id="map-canvas">
				    </div>
				</div>
			    <div class="panel panel-primary">
					<div class="panel-heading">
						<h3 class="panel-title">Vehicle Stats</h3>
					</div>
					<div class="panel-body">
						<ul class="list-group">
							<li class="list-group-item">
								<label>Odometer:</label> <span id="tcOdometer">Not Available</span>
							</li>
							<li class="list-group-item">
								<label>Fuel Level:</label> 
								<div class="progress">
									<div id="fuelLevel" class="progress-bar progress-bar-success" role="progressbar" aria-valuenow="40" aria-valuemin="0" aria-valuemax="100"><span class="sr-only">40% Complete (success)</span></div>
								</div>
							</li>
							<li class="list-group-item">
								<label>Location (lat,lng):</label> <span id="tcLatLng">Not Available</span>
							</li>
						</ul>
					</div>
				</div>
			</div>
			<div class="col-xs-6">		

				<ul class="nav nav-pills">
				  <li id="gasStationsPill" role="presentation" class="active" onclick="activeTab('dealerships', 'gasStations');"><a href="#">Gas Stations</a></li>
				  <li id="dealershipsPill" role="presentation" onclick="activeTab('gasStations', 'dealerships');"><a href="#">Dealers</a></li>
				</ul>

				<div id="data-tables">
				    <div class="panel panel-primary">
						<div class="panel-heading">
							<h3 class="panel-title">Nearby Locations</h3>
						</div>
						<div class="panel-body">
					    	<table id="gasStations" class="table table-striped">
					    		<tbody>
					    			<tr><td>No Information Available</td></tr>
					    		</tbody>
					    	</table>
					    	<table id="dealerships" class="table table-striped" style="display:none;">
					    		<tbody>
					    			<tr><td>No Information Available</td></tr>
					    		</tbody>
					    	</table>
				    	</div>
				    </div>
			    </div>
		    </div>
	  	</div>
	</div>    
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>
  	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>    
    <asset:javascript src="jquery.timer.js"/>
    <!-- TODO: move key out of the HTML -->
    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBywCGRuSOk1a0hJed2vOn3lZH6OIZbQ0E"
            type="text/javascript"></script>
            
    <g:javascript>
    	window.grailsSupport = {
    		assetsRoot : '${ raw(asset.assetPath(src: '')) }'
    	};
    </g:javascript>
    
    <script type="text/javascript">

    function initialize() 
    {
        var mapOptions = 
        {
          center: { lat: 39.833333, lng: -98.583333},
          zoom: 4
        };
        var map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
    }
    google.maps.event.addDomListener(window, 'load', initialize);

    // TODO: consider not hardcoding this
    var BRAND = "ford";
    
    </script>
	    
    <script type="text/javascript">

    	var map;
    	var marker;
    	
        var timer = $.timer(function() {
        	callRetreiveVehicleInfo( vehicleInfoSuccessCallback, vehicleInfoErrorCallback)
        });

        // The timer used to consistently retrieve Vehicle Data
        // Note: The time is in milliseconds
        // Note: 5 seconds isn't long enough
        timer.set( { time: 5000, autstart: false });
    	
        function startTimer() 
        {
        	timer.play()
        } 

        function stopTimer()
        {
            timer.pause();
        }
        

    	function vehicleInfoSuccessCallback( data, textStatus, jqXHR )
    	{
        	console.debug("vehicleInfoSuccessCallback()");
        	console.debug( data, textStatus, jqXHR );

        	console.debug( data.latitude );
        	console.debug( data.longitude );
        	console.debug( data.fuelLevel );
        	console.debug( data.odometer  );

        	$( "#tcOdometer").html( data.odometer == null ? "n/a" : data.odometer);
        	$( "#tcFuelLevel").html( data.fuelLevel == null ? "n/a" : data.fuelLevel);
        	$('#fuelLevel').css('width', data.fuelLevel+'%').attr('aria-valuenow', data.fuelLevel);

        	var latlngStr = "";
        	if (data.latitude != null && data.longitude != null)
           	{
               	latlngStr = data.latitude + ", " + data.longitude;
               	
               	// create a new google map or update it if one already exists
               if (marker != null && map != null) {
                 map = updateMap( data.latitude, data.longitude );
               }
               else {
                 map = addLatLngToNewMap( data.latitude, data.longitude);
               }

               // find the nearest gas stations
               callNearestGasSations( map, data.latitude, data.longitude, nearestGasStationErrorCallback)

               // find the nearest dealerships
               callNearestDealerships( map, BRAND, data.latitude, data.longitude, nearestDealershipErrorCallback)               
            }

            $( "#tcLatLng").html( latlngStr );
        	        	
        }

        function addLatLngToNewMap( latitude, longitude)
        {
            console.debug("adding latlng to map");
            
        	var mapCanvas = $( "#map-canvas")[0];
           	var latlng = new google.maps.LatLng (latitude, longitude);
           	var mapOptions = {
                   	center: latlng,
                   	zoom: 13,
                   	mapTypeId: google.maps.MapTypeId.ROADMAP
            }
            map = new google.maps.Map( mapCanvas, mapOptions);

            var markerOptions = {
                    position: latlng,
                    title: "Current Vehicle Location",
                    map: map
            }

            marker = new google.maps.Marker( markerOptions );

            return map;
        }

        function updateMap(latitude, longitude)
        {
            var latlng = new google.maps.LatLng( latitude, longitude );
            marker.setPosition( latlng );
            map.panTo( latlng );
			return map;
        } 

        function vehicleInfoErrorCallback( jqXHR, textStatus, errorThrown)
        {
        	// TODO: show an alert??
            console.debug("(vehicleInfo) An error occurred");
            console.debug( jqXHR, textStatus, errorThrown );
        }
      
        function callRetreiveVehicleInfo(successCallback, errorCallback)
        {
            console.debug("Calling vehicle stats web service...");
            $.ajax({
                	 url: 'map/vehicleStats',
                     cache: false,
                     success: successCallback,
                     error: errorCallback
                });
        }

        function nearestDealershipErrorCallback(jqXHR, textStatus, errorThrown)
        {
            // TODO: show an alert??
            console.debug("(nearestDealership) An error occurred");
            console.debug( jqXHR, textStatus, errorThrown );   
        }

        function callNearestDealerships(map, brand, lat, lng, errorCallback)
        {
			console.debug("Calling the nearest dealerships service")
			var theUrl = 'map/nearestDealerships?brand=' + brand + '&lat=' + lat + "&lng=" + lng
            console.debug('The url is ' + theUrl);

            $.ajax({
                url: theUrl,
                type: 'GET',
                cache: false,
                success: function (data, textStatus, jqXHR) {
                    console.debug("nearestDealershipSuccessCallback()");
                    console.debug(data);

                    var iconUrl = window.grailsSupport.assetsRoot + 'dealership.png';

					console.debug('the icon url is ' + iconUrl);
                    
                    console.debug("There are " + data.dealers.length + " dealerships nearby");

                    // clear the gas stations div
                    $( "#dealerships tbody").empty();
                    
                   
                    for(var i=0; i<data.dealers.length;i++)
                    {
                        var dealership = data.dealers[i];

                        console.debug("Adding dealership " + dealership.name + " to the map (" + dealership.address.latitude + ", " + dealership.address.longitude + ")");

                        var title = dealership.name + "\n" + 
                        	dealership.address.street + ", " + dealership.address.city + ", " + dealership.address.stateCode + " " + dealership.address.zipcode;

                        addMarkerToMap(map, dealership.address.latitude, dealership.address.longitude, iconUrl, title); 

                        $( "#dealerships tbody").append(buildDealershipList(dealership.name, dealership.address.street, dealership.address.city, dealership.address.stateCode, dealership.address.zipcode, dealership.distance));
                    }

                    if (data.length=0)
                    {
                        $( "#dealerships tbody").append('<tr><td>No Nearby Dealerships</td></tr>');
                    }
                    
                },
                error: errorCallback
            
            });
			// TODO: Implement
           
        }

        function nearestGasStationErrorCallback( jqXHR, textStatus, errorThrown)
        {
            // TODO: show an alert??
            console.debug("(nearestGasStation) An error occurred");
            console.debug( jqXHR, textStatus, errorThrown );            
        }

        function addMarkerToMap(map, lat, lng, iconUrl, title)
        {
            var latlng = new google.maps.LatLng ( lat, lng );
            
            var mapIcon = {
                    url: iconUrl,
                    size: new google.maps.Size(71,71),
                    orign: new google.maps.Point(0, 0),
                    anchor: new google.maps.Point(17, 34),
                    scaledSize: new google.maps.Size(50,50)
            
            }

            var markerOptions = {
                    icon: mapIcon,
                    position: latlng,
                    title: title,
                    map: map
            }

            var marker = new google.maps.Marker( markerOptions );
        }

        function callNearestGasSations(map, lat, lng, errorCallback)
        {
            console.debug("Calling the nearest gas station service")
            var theUrl = 'map/nearestGasStations?lat=' + lat + "&lng=" + lng
            console.debug('The url is ' + theUrl);
            
            $.ajax({
                url: theUrl,
                type: 'GET',
                cache: false,
                success: function (data, textStatus, jqXHR) {

                    console.debug("nearestGasStationSuccessCallback()");
                    console.debug( data );
                    console.debug("textstatus...")
                    console.debug( textStatus );
                    console.debug("jqXHR...");
                    console.debug( jqXHR );

                    var iconUrl = window.grailsSupport.assetsRoot + 'gasstation.png';
                    
                    console.debug('the icon url is ' + iconUrl);
                    
                    console.debug("There are " + data.length + " gas stations nearby");

                    // clear the gas stations div
//                    $( "#gasStations").html("");
                    
                    $( "#gasStations tbody").empty();
                    
                    for(var i=0; i<data.length;i++)
                    {
                        var gasStation = data[i];

                        console.debug("Adding gas station " + gasStation.Name + " to the map. (" + gasStation.Lat + ", " + gasStation.Lng + ")");                        

                        addMarkerToMap(map, gasStation.Lat, gasStation.Lng, iconUrl, gasStation.Name + "\n" + gasStation.Address + "\n");

                        $( "#gasStations tbody").append(buildGasStationList( gasStation.Name, gasStation.Address));
                    }

                    if (data.length=0)
                    {
                        $( "#gasStations tbody").append('<tr><td>No Nearby Gas Stations</td></tr>');
                    }
                },
                error: errorCallback
            })
        }  

        function buildGasStationList(name, address)
        {
            var html = '<tr><td><strong>' + name + '</strong></td><td>' + address + '</td></tr>';
            return html;
        }

        function buildDealershipList(name, street, city, state, zipCode, distance)
        {
            var html = '<tr><td><strong>' + name + "</strong></td><td>" + street + " " + city + " " + state + " " + zipCode + "<br/>" + "Distance: " + distance + " miles" + "</td></tr>";
            return html;
        }

        function activeTab(disabledId, activeId) {
			$('#' + disabledId).hide();
			$('#' + disabledId + "Pill").removeClass('active');
			$('#' + activeId).show();
			$('#' + activeId + "Pill").addClass('active');
        }
        
    </script>
  </body>
</html>
