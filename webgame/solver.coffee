
cards = document.getElementsByClassName('card')
restCards = Array.prototype.slice.call cards
colors = {}

first = true

doClick = (card) ->
  return unless card?
  ev = document.createEvent 'MouseEvents'
  ev.initEvent 'click', false, true
  card.dispatchEvent ev

  first = !first

  color = card.style.backgroundColor
  console.log("clicked #{card.id}, color is #{color}")
  color

while(restCards.length > 0)
  card = restCards.shift()
  color = doClick card

  colors[color] = [] unless colors[color]?
  colors[color].push card

  if colors[color].length > 1
    doClick colors[color][0]
    doClick colors[color][1] unless first
