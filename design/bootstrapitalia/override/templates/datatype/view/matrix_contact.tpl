{let matrix=$attribute.content}
    {foreach $matrix.rows.sequential as $row}
        {def $type = $row.columns[0]
        	 $contact = $row.columns[2]
        	 $value = $row.columns[1]}
        <p class="mb-1">
            {if or($type|ne(''), $contact|ne(''))}
            <strong>{$type|wash()}{if $contact|ne('')} - {$contact|wash()}{/if}:</strong>
            <br/>
            {/if}
            {if $value|begins_with('http')}
            	<a class="d-inline" href="{$value|wash()}">{$value|wash()}</a>
            {elseif $value|contains('@')}
            	<a class="d-inline" href="mailto:{$value|wash()}">{$value|wash()}</a>
            {elseif or($type|downcase|begins_with('tel'),
              $type|downcase|begins_with('cel'),
              $type|downcase|begins_with('phon'),
              $type|downcase|begins_with('mob'))}
              <a class="d-inline" href="tel:{$value|wash()}">{$value|wash()}</a>
            {else}
            	<span>{$value|wash()}</span>
        	{/if}
        </p>
        {undef $type $contact $value}
    {/foreach}
{/let}

