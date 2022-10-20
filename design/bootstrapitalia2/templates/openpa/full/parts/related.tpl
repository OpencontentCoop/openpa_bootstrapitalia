{if $node|has_attribute('topics')}
	{def $topic_id_list = array()}
	
	{foreach $node|attribute('topics').content.relation_list as $item}
		{set $topic_id_list = $topic_id_list|append($item.contentobject_id)}
	{/foreach}
	
	{def $top_menu_node_ids = openpaini( 'TopMenu', 'NodiCustomMenu', array() )}
	{def $data = array()}

	{if count($top_menu_node_ids)|gt(0)}
		
		{foreach $top_menu_node_ids as $id max 4}
			{def $top_menu_node = fetch(content, node, hash(node_id, $id))}
				{def $contents = api_search(concat('topics.id in [', $topic_id_list|implode(','), '] and id != ', $node.contentobject_id, ' subtree [', $id, '] sort [modified=>desc] limit 4'))}
				{if $contents.totalCount|gt(0)}
					{set $data = $data|append(hash(
						'title', $top_menu_node.name|wash(),
						'icon', cond($top_menu_node|has_attribute('icon'), $top_menu_node|attribute('icon').content|wash(), false()),
						'contents', $contents.searchHits
					))}
				{/if}
				{undef $contents}
			{undef $top_menu_node}
		{/foreach}
		{if count($data)|gt(0)}
		<section id="contenuti-correlati">
		    <div class="section section-muted section-inset-shadow">
		        <div class="section-content">
		            <div class="container">
		                <div class="row">
		                    <div class="col">
		                        <h3 class="text-center">{'Related contents'|i18n('bootstrapitalia')}</h3>
		                    </div>
		                </div>
		                <div class="row mt-lg-4">		                    
		                    <div class="col">
		                        <div class="card-wrapper card-teaser-wrapper card-teaser-wrapper-equal card-teaser-block-{count($data)}">                            
		                            {foreach $data as $item}
	                                    <div class="card card-teaser card-column shadow my-3 rounded">
	                                        <div class="card-header">
	                                            {if $item.icon}
	                                                {display_icon($item.icon, 'svg', 'icon')}
	                                            {/if}
	                                            <h5 class="card-title">
	                                                {$item.title|wash()}
	                                            </h5>
	                                        </div>
	                                        <div class="card-body">
	                                            <div class="link-list-wrapper mt-3">
	                                                <ul class="link-list">
	                                                {foreach $item.contents as $item}
	                                                    <li><a class="list-item" href="{concat('content/view/full/',$item.metadata.mainNodeId )|ezurl(no)}">
	                                                    	<span>
                                                                {if is_set($item.metadata.name[ezini('RegionalSettings','Locale')])}
                                                                    {$item.metadata.name[ezini('RegionalSettings','Locale')]|wash()}
                                                                {else}
                                                                    {foreach $item.metadata.name as $locale => $name}
                                                                        {$name|wash()}
                                                                        {break}
                                                                    {/foreach}
                                                                {/if}
                                                            </span></a>
                                                    	</li>
                                                    {/foreach}
	                                                </ul>
	                                            </div>
	                                        </div>
	                                    </div>
		                            {/foreach}
		                        </div>
		                    </div>		                    
		                </div>
		            </div>
		        </div>
		    </div>
		</section>
		{/if}
	{/if}

	{undef $top_menu_node_ids $data}
{/if}