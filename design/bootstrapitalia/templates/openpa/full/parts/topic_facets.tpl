{def $current_node_topic_node_id_list = api_search(concat('subtree [', $current_node.node_id, '] facets [raw[submeta_topics___main_node_id____si]|alpha|100] limit 1')).facets[0].data}
{if $current_node_topic_node_id_list|count()}
<section class="py-5">
    <div class="container">
        
        <div class="row">
            <div class="col-md-12">
                <h3 class="mb-4 text-primary">Argomenti</h3>
            </div>
        </div>

		<div class="col text-center">
			{foreach $current_node_topic_node_id_list as $id => $count}
            	{def $topic = fetch(content, node, hash(node_id, $id))}
            	<a href="{concat('content/search/?Topic[]=', $topic.node_id, '&Subtree[]=', $current_node.node_id)|ezurl(no)}"><span class="chip chip-simple chip-primary"><span class="chip-label">{$topic.name|wash()}</span></span></a>
            	{undef $topic}
            {/foreach}
		</div>

    </div>
</section>
{/if}
{undef $current_node_topic_node_id_list}