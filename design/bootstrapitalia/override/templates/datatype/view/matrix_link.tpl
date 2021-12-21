{let matrix=$attribute.content}
    <div class="link-list-wrapper">
        <ul class="link-list">
            {foreach $matrix.rows.sequential as $row}
            {if $row.columns[1]|ne('')}
                <li>
                    <a href="{$row.columns[1]|wash()}" target="_blank" rel="noopener noreferrer">
                        {display_icon('it-link', 'svg', 'icon icon-sm')}
                        {$row.columns[0]|wash()} <i aria-hidden="true" class="fa fa-external-link"></i>
                    </a>
                </li>
            {/if}
            {/foreach}
        </ul>
    </div>
{/let}

