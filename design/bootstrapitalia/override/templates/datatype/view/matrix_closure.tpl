{let matrix=$attribute.content}
<ul class="list-inline">{foreach $matrix.rows.sequential as $row}<li class="list-inline-item">{$row.columns[0]|wash()}</li>{/foreach}</ul>
{/let}
