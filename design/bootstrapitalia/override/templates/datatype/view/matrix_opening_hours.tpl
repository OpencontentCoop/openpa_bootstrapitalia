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
		<dt class="col-2 text-nowrap{if $i|gt(0)} border-top pt-1{/if}">{$column.identifier|i18n('bootstrapitalia/opening_hours_matrix_short')|wash()}</dt><dd class="col-10{if $i|gt(0)} border-top pt-1{/if}"><span class="text-nowrap">{$value|implode('</span>, <span class="text-nowrap">')}</span></dd>
		{set $i = $i|inc()}
	{/if}
	{undef $value}
	
{/foreach}
</dl>
{if and(is_set($container_has_image), $container_has_image)}</div>{/if} 	 

{undef $matrix $i}
