<section id="czar">
  <%= game.current_black_card %>
  <ol class="answers">
    <% _.each(game.answers, function(answers) { %>
      <li>
        <% if(answers.length > 1) { %>
        <ol>
          <% _.each(answers, function(answer) { %>
            <li>
              <%= answer %>
            </li>
          <% }); %>
        </ol>
        <% } else { %>
          <%= answers %>
        <% } %>
      </li>
    <% }); %>
  </ol>
  <button class="read-answers">Read Answers</button>
</section>
