{def $matrix=$attribute.content
 	 $i = 0}
{if and(is_set($container_has_image), $container_has_image)}<div class="position-relative mr-n5">{/if} 	 
<dl class="matrix_opening_hours row my-2{if and(is_set($container_has_image), $container_has_image)} position-relative mr-n5{/if}">
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
{if and(is_set($container_has_image), $container_has_image)}</div>{/if} 	 

{undef $matrix $i}