{let matrix=$attribute.content}
    {foreach $matrix.rows.sequential as $row}
        <p class="mb-1">
            <strong>{$row.columns[0]|wash()}{if $row.columns[2]|ne('')} - {$row.columns[2]|wash()}{/if}:</strong> 
            <br/><span>{$row.columns[1]|wash()}</span>
        </p>
    {/foreach}
{/let}

