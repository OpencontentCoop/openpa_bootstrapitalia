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
		    <div class="bg-grey-card shadow-contacts">
		        <div class="section-content">
		            <div class="container">
		                <div class="row">
		                    <div class="col-12 pt-5">
		                        <h3 class="text-center cmp-carousel__title">{'Related contents'|i18n('bootstrapitalia')}</h3>
		                    </div>
		                </div>
		                <div class="row mt-lg-4 pb-5">
                            {foreach $data as $item}
                            <div class="col">
                                <div class="card-wrapper card-space h-100 pb-4">
                                    <div class="card card-bg single-card rounded shadow-sm">
                                        <div class="cmp-carousel__header">
                                            {if $item.icon}
                                                {display_icon($item.icon, 'svg', 'icon')}
                                            {/if}
                                            <span class="ms-3 cmp-carousel__header-title">{$item.title|wash()}</span>
                                        </div>
                                        <div class="card-body">
                                            <div class="link-list-wrapper">
                                                <ul class="card-body__list">
                                                    {foreach $item.contents as $item}
                                                        <li><a class="list-item px-0" href="{concat('content/view/full/',$item.metadata.mainNodeId )|ezurl(no)}">
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
                                </div>
                            </div>
                            {/foreach}
		                </div>
		            </div>
		        </div>
		    </div>
		</section>
		{/if}
	{/if}

	{undef $top_menu_node_ids $data}
{/if}