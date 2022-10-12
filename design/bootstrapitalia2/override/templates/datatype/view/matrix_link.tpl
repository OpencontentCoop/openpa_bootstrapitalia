{let matrix=$attribute.content}
    <ul class="link-list">
        {foreach $matrix.rows.sequential as $row}
            {if $row.columns[1]|ne('')}
                <li>
                    <div class="cmp-icon-link">
                        <a href="{$row.columns[1]|wash()}" target="_blank" rel="noopener noreferrer"
                           class="list-item icon-left d-inline-block font-sans-serif">
                            <span class="list-item-title-icon-wrapper">
                                {display_icon('it-link', 'svg', 'icon icon-primary icon-sm me-1')}<span class="list-item">{$row.columns[0]|wash()} <i aria-hidden="true" class="fa fa-external-link"></i></span>
                            </span>
                        </a>
                    </div>
                </li>
            {/if}
        {/foreach}
    </ul>
{/let}

