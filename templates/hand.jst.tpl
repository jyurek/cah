<header class="current-card"><%= game.current_black_card %></header>
<ul class="cards">
  <% _.each(game.myCards(), function (card) { %>
    <li class="card"><%= card %></li>
  <% }); %>
</ul>

<button class="use-cards" style="display:none">Use This Answer</button>
