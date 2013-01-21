<header class="current-card"><%= game.current_black_card %></header>
<ol class="cards">
  <% _.each(game.myCards(), function (card) { %>
    <li class="card"><%= card %></li>
  <% }); %>
</ol>

<button class="use-cards" style="display:none">Use This Answer</button>
