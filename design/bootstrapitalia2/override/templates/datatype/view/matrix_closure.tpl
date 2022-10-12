{let matrix=$attribute.content}
<ul class="list-inline m-0">{foreach $matrix.rows.sequential as $row}<li class="list-inline-item">{$row.columns[0]|wash()}{if $row.columns[1]|ne('')}: {$row.columns[1]|wash()}{/if}</li>{/foreach}</ul>
{/let}
