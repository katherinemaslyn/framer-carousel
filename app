# INITIAL STATE

# Import file "NessSERP"
sketch = Framer.Importer.load("imported/NessSERP@1x")

# Set number of cards in prototype
firstCard = 1
maxCard = 9
cardsInSketchFile = 9

# Hide any unused cards in Sketch file
for i in [cardsInSketchFile...maxCard]
	sketch["card#{i}"].opacity = 0
for i in [1...firstCard]
	sketch["card#{i}"].opacity = 0

# Hide unused layers
sketch.placeholderLeft.opacity = 0
sketch.placeholderRight.opacity = 0
sketch.page_controller.opacity = 0

# Initial position first card
sketch["card#{firstCard}"].x = 94
sketch["card#{firstCard}"].y = 268
sketch["card#{firstCard}"].z = 2
sketch["card#{firstCard}"].scale = 1
sketch["card#{firstCard}"].originX = 0
sketch["card#{firstCard}"].originY = 0
lastCardDragged = firstCard

# Initial position second card
sketch["card#{firstCard+1}"].x = 700
sketch["card#{firstCard+1}"].y = 300
sketch["card#{firstCard+1}"].z = 1
sketch["card#{firstCard+1}"].scale = 0.85
sketch["card#{firstCard+1}"].originX = 0
sketch["card#{firstCard+1}"].originY = 0

# Initial position all other cards
for i in [(firstCard+2)..maxCard]
	sketch["card#{i}"].x = 1100
	sketch["card#{i}"].y = 300
	sketch["card#{i}"].z = 0
	sketch["card#{i}"].scale = 0.85
	sketch["card#{i}"].originX = 0
	sketch["card#{i}"].originY = 0

# Define states to be used
for i in [firstCard..maxCard]
	sketch["card#{i}"].states.add
		left: x: -510, y: 300, z: 1, scale: 0.85, originX: 1, originY: 0
		center: x: 94, y: 268, scale: 1, originX: 0, originY: 0, z: 2
		right: x: 700, y: 300, scale: 0.85, originX: 0, originY: 0, z:1
		offLeft: x: -910, y: 300, scale: 0.85, originX: 0, originY: 0, z:0
		offRight: x:1100, y: 300, scale: 0.85, originX: 0, originY: 0, z:0
	sketch["card#{i}"].states.animationOptions = curve: 'spring(200, 20, 0)'

# HELPER FUNCTIONS

lockAllExcept = (activeCard) ->
	for i in [firstCard..maxCard]
		if activeCard == i
			sketch["card#{i}"].draggable.enabled = true
			sketch["card#{i}"].draggable.vertical = false
		else
			sketch["card#{i}"].draggable.enabled = false
			sketch["card#{i}"].draggable.vertical = false

stateStart = () ->
	sketch["card#{firstCard}"].states.switch('center')
	sketch["card#{firstCard+1}"].states.switch('right')
	for i in [firstCard+2..maxCard]
		sketch["card#{i}"].states.switch('offRight')
	lockAllExcept(firstCard)

stateEnd = () ->
	sketch["card#{maxCard}"].states.switch('center')
	sketch["card#{maxCard-1}"].states.switch('left')
	for i in [firstCard..maxCard-2]
		sketch["card#{i}"].states.switch('offLeft')
	lockAllExcept(maxCard)

stateMiddle = (centerCard) ->
	for i in [firstCard..maxCard]
		#if the card should be in the off left pile
		if i < centerCard-1
			sketch["card#{i}"].states.switch('offLeft')
		#if the card should occupy left position
		else if i == centerCard-1
			sketch["card#{i}"].states.switch('left')
		#if the card should occupy center position
		else if i == centerCard
			sketch["card#{i}"].states.switch('center')
		#if the card should occupy right position
		else if i == centerCard+1
			sketch["card#{i}"].states.switch('right')
		#if the card should be in the off right pile
		else #if i > centerCard+1
			sketch["card#{i}"].states.switch('offRight')
	lockAllExcept(centerCard)

setEventsForCard = (cardNumber) ->
	sketch["card#{cardNumber}"].on Events.DragEnd, ->
		# if swiped left and cleared threshold
		if sketch["card#{cardNumber}"].x < 15
			if lastCardDragged == maxCard
				stateEnd()
			else if lastCardDragged < maxCard
				lastCardDragged++
				stateMiddle(lastCardDragged)
			else
				print "error: swipe left in setEventsForCard"
		# if swiped right and cleared threshold
		else if sketch["card#{cardNumber}"].x > 160
			if lastCardDragged == firstCard
				stateStart()
			else if lastCardDragged > firstCard
				lastCardDragged--
				stateMiddle(lastCardDragged)
			else
				print "error: swipe right in setEventsForCard"
		# if swiped left or right and didn't clear threshold
		else
			if lastCardDragged == firstCard
				stateStart()
			else if lastCardDragged == maxCard
				stateEnd()
			else
				stateMiddle(lastCardDragged)

# MAIN DRIVER (HANDLE DRAG EVENTS)

lockAllExcept(firstCard)
for i in [firstCard..maxCard]
	setEventsForCard(i)
