package io.pivotal.demo.controller;

import io.pivotal.demo.Dealerships;
import io.pivotal.demo.Geo;
import io.pivotal.demo.GasStations;
import io.pivotal.demo.Schedule;
import io.pivotal.demo.VehicleInfo;
import io.pivotal.demo.service.DealershipsClient;
import io.pivotal.demo.service.GeocodeClient;
import io.pivotal.demo.service.RepairClient;
import io.pivotal.demo.service.GasStationClient;

import java.util.List;

import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;

@Controller
@RequestMapping("/map")
public class MapController {
    
	private static final String queueName = "vehicle-data-queue";
	
    @Autowired
    private RepairClient repairClient;

    @Autowired
    private GasStationClient gasStationClient;

    @Autowired
    private GeocodeClient geocodeClient;
    
    @Autowired
    private DealershipsClient dealershipsClient;
    
    @Autowired 
    private RabbitTemplate rabbitTemplate;
    
    @RequestMapping("/dealershipOpenings")
	public @ResponseBody List<Schedule> dealershipOpenings(@RequestParam(required=true) Long dealerId) {
		return repairClient.openings(dealerId);
	} 
    
    
	// URL Example: /nearestGasStationsWithPrices?lat=42.221786&lng=-83.414139&distance=5
    @RequestMapping(value = "/nearestGasStationsWithPrices")
	public @ResponseBody GasStations nearestGasStationsWithPrices(@RequestParam(required=true) String lat, 
																  @RequestParam(required=true) String lng,
																  @RequestParam(required=true) Integer distance) {
		return gasStationClient.nearestGasStationsWithPrices(lat, lng, distance);
		
	}    

    @RequestMapping("/nearestDealerships")
	public @ResponseBody Dealerships nearestDealerships(@RequestParam(required=true) String lat, 
															 @RequestParam(required=true) String lng,
															 @RequestParam(required=true) String brand) {
		Geo geo = geocodeClient.geocode(lat, lng);
		return dealershipsClient.nearestDealerships(brand, geo.getPostalCode());
		
	}    
    
    @RequestMapping("/vehicleInfo")
    public @ResponseBody VehicleInfo vehicleInfo() throws Exception {

    	String json = new String((byte[])rabbitTemplate.receiveAndConvert(queueName));
		
    	ObjectMapper mapper = new ObjectMapper();
		mapper.disable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES);
		
		return mapper.readValue(json, VehicleInfo.class);        
    }

}
