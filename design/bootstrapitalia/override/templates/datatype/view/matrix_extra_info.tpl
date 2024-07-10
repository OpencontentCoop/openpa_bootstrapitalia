{def $key_values = hash()}
{foreach $attribute.content.rows.sequential as $row}
    {if $row.columns[1]|ne('')}
        {set $key_values = $key_values|merge(hash($row.columns[1], $row.columns[2]))}
    {/if}
{/foreach}
<table class="table text-serif lora">
    {foreach $key_values as $key => $value}
        <tr>
            <th class="ps-0">{$key|wash()}</th>
            <td class="ps-0">{$value|wash()}</td>
        </tr>
    {/foreach}
</table>

{undef $key_values}