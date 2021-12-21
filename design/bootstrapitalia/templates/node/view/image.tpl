{if and(is_set($node.data_map.image), $node.data_map.image.data_type_string|eq('ezimage'), $node.data_map.image.has_content)}

	<h2>{$node.name}</h2>
	{if $node|has_attribute('caption')}
        {$node|attribute('caption').content.output.output_text|oc_shorten(200,'...')}    
    {/if}

    <small class="d-block" style="font-size:.8em" data-image-node="{$node.main_node_id}">
        {if $node|has_attribute('author')}
            &copy; {attribute_view_gui attribute=$node|attribute('author')} - 
        {/if}
        {if $node|has_attribute('proprietary_license')}
            {def $proprietary_license_source = false()}
            {if $node|has_attribute('proprietary_license_source')}
                {set $proprietary_license_source = $node|attribute('proprietary_license_source').content}
            {/if}
            {if $proprietary_license_source|begins_with('http')}
                <a href="{$proprietary_license_source}">
            {else}
                <span title="{$proprietary_license_source}">
            {/if}
                {attribute_view_gui attribute=$node|attribute('proprietary_license')}
            {if $proprietary_license_source|begins_with('http')}
                </a>
            {else}
                </span>
            {/if}
            {undef $proprietary_license_source}
        {elseif $node|has_attribute('license')}
            {$node|attribute('license').content.keyword_string|wash()}
        {/if}
    </small>

	
	{def $keys = array('width','height','mime_type','filename','alternative_text','url','filesize')}
	
	{foreach array('original', 'rss','small', 'medium','widemedium','large','reference') as $alias}

		<div class="py-4">
			<h4>{$alias}</h4>
			{if $alias|ne('original')}
			{attribute_view_gui attribute=$node.data_map.image
	                            image_class=$alias
	                            image_css_class=''
	                            fluid=false()}
			{/if}
			<p>
				{foreach $node.data_map.image.content[$alias] as $name => $value}
					{if $keys|contains($name)}
						<strong>{$name}: </strong>					
						{if $name|eq('url')}
						  <a target="_blank" rel="noopener noreferrer" href={$value|ezroot()}>{$value|wash()}</a>
						{elseif $name|eq('filesize')}
						  {$value|si(byte)}
						{else}
						  {$value|wash()}
						{/if}					
						<br/>
					{/if}
				{/foreach}
			</p>
			
			{if $alias|ne('original')}
			<div class="bg-light p-3">
				<code>Reference={ezini($alias, 'Reference', 'image.ini')}</code><br />
				{foreach ezini($alias, 'Filters', 'image.ini') as $filter}
					<code>Filters[]={$filter|wash()}</code>
					{delimiter}<br />{/delimiter}
				{/foreach}			
			</div>
			{/if}
		</div>

	{/foreach}

{/if}

