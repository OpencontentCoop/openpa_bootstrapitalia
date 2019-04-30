{def $matrix=$attribute.content
 	 $i = 0}

<dl class="row my-2">
{foreach $matrix.columns.sequential as $index => $column}
	{def $value = array()}
	{foreach $matrix.rows.sequential as $row}
		{if $row.columns[$index]|ne('')}
			{set $value = $value|append($row.columns[$index]|wash())}
		{/if}
	{/foreach}
	{if count($value)|gt(0)}
		<dt class="col-2{if $i|gt(0)} border-top pt-1{/if}">{$column.name|wash()|shorten( 3, '')}</dt><dd class="col-10{if $i|gt(0)} border-top pt-1{/if}">{$value|implode(', ')}</dd>
		{set $i = $i|inc()}
	{/if}
	{undef $value}
	
{/foreach}
</dl>

{undef $matrix $i}