package io.pivotal.demo

import org.codehaus.groovy.grails.commons.GrailsApplication;

import grails.converters.JSON
import grails.plugins.rest.client.RestBuilder
import io.pivotal.demo.VehicleMessageConsumer

class MapController {
	
	def grailsApplication
	
	// TODO: Don't hard code these values
	def static vehicleMessageConsumer
	
    def index() 
	{ 
		flash.message = null
	}
	
	def startTracking()
	{
		println "startTracking()"
					
		flash.message = "Vehicle tracking has been STARTED."
		
		render view: 'index'
	}
	
	def stopTracking()
	{
		println "stopTracking"
		
		flash.message = "Vehicle tracking has been STOPPED."
		
		render view: 'index'
	}
	
	def vehicleStats()
	{
		println "vehicleStats"
		
		def info = vehicleMessageConsumer.retrieveVehicleInfo();
		
		println "Vehicle Stats {$info}"
		
		render info as JSON
	}
	
	def nearestGasStations()
	{
		println "Nearest Gas Stations"
		
		def lat = params.lat
		def lng = params.lng
		
		println "Latitude, Longitude is ${lat}, ${lng}"

		def restBuilder = new RestBuilder()
		
		def url = grailsApplication.config.io.pivotal.demo.google.places.gas.url + lat + '/' + lng
		
		println "The google places URL is ${url}" 
		
		def response = restBuilder.get(url)
		
		println "The response is ${response.json}"
		
		render response.json as JSON
	}
	
	def nearestDealerships()
	{
		println "Nearest Dealerships"
		
		def lat = params.lat
		def lng = params.lng
		def brand = params.brand
		
		println "Latitude, Longitude is ${lat}, ${lng}. Brand is {$brand}"
		
		// first we need to get the zip code...
		def restBuilder = new RestBuilder()
		
		def url = grailsApplication.config.io.pivotal.demo.google.geocode.url + lat + '/' + lng
		
		println "The reverse geo URL is {$url}"
		
		def response = restBuilder.get(url)
		
		def postalCode = response.json.postalCode
		
		// TODO: make sure postalCode is okay and if not, return an error
		
		def dealerUrl = grailsApplication.config.io.pivotal.demo.dealer.service.url + brand + '/' + postalCode
		def rest = new RestBuilder();
		def dealerResponse = rest.get(dealerUrl);
		
		println "The dealer response (JSON) is {$dealerResponse.json}"
		
		render dealerResponse.json as JSON
	}
}
