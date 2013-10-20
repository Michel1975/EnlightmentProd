# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  Morris.Line
    element: 'subscribers_chart'
    data: $('#subscribers_chart').data('subscribers')
    xkey: 'created_date'
    ykeys: ['total']
    labels: ['Antal']
    xLabels: 'day'
    