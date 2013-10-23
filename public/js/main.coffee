
#
# Changes CSS properties on a section to give it a sticky effect
#
# @param  current   {jq object}      current DOM section in view
# @param  stages    {jq object arr}  DOM element collection
# @param  direction {string}         direction waypoint was reached
# @return true
#

switchStage = (current, stages, direction) ->

  i = current.index()
  h = $(window).height()
  w = $(window).width()

  if direction == 'down' and i != stages.length
    current.next().css marginTop: h * current.index()
    current.css
      height: h
      width: w
      marginTop: 0
      position: 'fixed'
      left: 0
      top: 0

  if direction == 'up' and i != stages.length
    current.next().css marginTop: 0
    current.css
      position: 'relative'
      marginTop: h * (current.index() - 1)

#
# Initial stage set up and waypoint execution
#
# @param  stages {jq object} collection of DOM elements
# @return true
#

setupStages = (stages, header) ->

  w = $(window).width()
  h = if not isMobile() then $(window).height() else 'auto'

  stages.waypoint('destroy')

  stages.css
    height: h
    width: w
    position: 'relative'
    margin: '0'

  if not isMobile()

    $("html").animate scrollTop: 0, 1
    $("body").animate scrollTop: 0, 1

    stages.waypoint (dir) -> switchStage($(this), stages, dir)

    stages.last().waypoint ((dir) ->
      color = ( if dir == 'down' then '#666666' else '#FFFFFF' )
      header.find('*').animate color: color
    ),
    offset: 30

#
# Updates the active project in the controls
#
# @param  args {object} passed iosslider object
# @return true
#

switchProjectControls = (args) ->

  controls = $('#project-controls')
  controls.find('a')
          .removeClass('active')
          .eq(args.currentSlideNumber - 1)
          .addClass('active')

#
# Loads the slider controls into the dom
#
# @param  args {object} passed iosslider object
# @return true
#

loadProjectControls = (args) ->
  controls = $('<div id="project-controls" class="project-controls"></div>')

  i = 1
  while i <= args.data.slideNodes.length
    link = $('<a href="#"></a>')
    link.addClass('active') if i == 1
    link.appendTo(controls)
    i++

  controls.on 'click', (e) ->
    if e.target.nodeName.toLowerCase() == 'a'
      args.sliderContainerObject.iosSlider('goToSlide', ($(e.target).index() + 1))
    e.preventDefault()

  args.sliderContainerObject.parent().append(controls)

#
# Returns if a mobile device is detected or not
#
# @return {boolean} true/false
#

isMobile = () ->
  if /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) then true else false


# DOM has been loaded...


$(document).ready ->

  header   = $("header")
  stages   = $("section")

  stages.css
    display:  'table'
    height:   '100%'
    position: 'relative'
    width:    '100%'

  projects =
    container: $('#projects')
    prev:      $("#prev-project")
    next:      $("#next-project")
    controls:  $("#project-controls")

  projects.container.iosSlider
    desktopClickDrag: true
    snapToChildren:   true
    keyboardControls: true
    infiniteSlider:   true
    navPrevSelector:  projects.prev
    navNextSelector:  projects.next
    onSlideChange:    switchProjectControls
    onSliderLoaded:   loadProjectControls

  services = $('div[data-service-id]')
  services_links = $('a[data-service]')

  services.not('.active').hide()

  services_links.on 'click', (e) ->
    id = $(this).data('service')
    current = $('div[data-service-id="' + id + '"]')
    services_links.removeClass('active')
    $(this).addClass('active')
    services.hide()
    current.show()
    e.preventDefault()

  $(window).resize( (e) -> setupStages(stages, header) ).resize()

  $('a[data-link]').on 'click', (e) ->
    target = $(this).data 'link'
    i = $('section.' + target).index() - 1
    endpoint = if $(window).width() > 700 then ( $(window).height() * i ) else $('.create').position().top
    $('html').animate scrollTop: endpoint, 1100 # IE
    $('body').animate scrollTop: endpoint, 1100
    e.preventDefault()




