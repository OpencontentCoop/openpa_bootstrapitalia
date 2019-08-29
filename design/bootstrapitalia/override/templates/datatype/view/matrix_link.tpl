{let matrix=$attribute.content}
    <div class="link-list-wrapper">
        <ul class="link-list">
            {foreach $matrix.rows.sequential as $row}
                <li>
                    <a href="{$row.columns[1]|wash()}">
                        {display_icon('it-link', 'svg', 'icon icon-sm')}
                        {$row.columns[0]|wash()}
                    </a>
                </li>
            {/foreach}
        </ul>
    </div>
{/let}

