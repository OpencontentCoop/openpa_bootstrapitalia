{let matrix=$attribute.content}
    <ul>
        {foreach $matrix.rows.sequential as $row}
        {if $row.columns[1]|ne('')}
            <li>
                <a href="{$row.columns[1]|wash()}">
                    {display_icon('it-link', 'svg', 'icon icon-sm')}
                    {$row.columns[0]|wash()}
                </a>
            </li>
        {/if}
        {/foreach}
    </ul>
{/let}

