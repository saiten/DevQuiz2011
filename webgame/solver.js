(function() {
  var card, cards, color, colors, doClick, first, restCards;
  cards = document.getElementsByClassName('card');
  restCards = Array.prototype.slice.call(cards);
  colors = {};
  first = true;
  doClick = function(card) {
    var color, ev;
    if (card == null) {
      return;
    }
    ev = document.createEvent('MouseEvents');
    ev.initEvent('click', false, true);
    card.dispatchEvent(ev);
    first = !first;
    color = card.style.backgroundColor;
    console.log("clicked " + card.id + ", color is " + color);
    return color;
  };
  while (restCards.length > 0) {
    card = restCards.shift();
    color = doClick(card);
    if (colors[color] == null) {
      colors[color] = [];
    }
    colors[color].push(card);
    if (colors[color].length > 1) {
      doClick(colors[color][0]);
      if (!first) {
        doClick(colors[color][1]);
      }
    }
  }
}).call(this);
