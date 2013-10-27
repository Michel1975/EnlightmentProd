# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
	Morris.Line
    	element: 'subscribers_recent'
    	data: $('#subscribers_recent').data('subscribers')
    	xkey: 'date'
    	ykeys: ['no_new_members', 'no_opt_outs']
    	labels: ['Antal tilmeldinger', 'Antal afmeldinger']
    	xLabels: 'day'
    	parseTime: false
    Morris.Bar
    	element: 'subscribers_bar'
    	data: $('#subscribers_bar').data('subscribers')
    	xkey: 'month'
    	ykeys: ['no_new_members', 'no_opt_outs']
    	labels: ['Antal tilmeldinger', 'Antal afmeldinger']
    	xLabels: 'month'
    	parseTime: false

