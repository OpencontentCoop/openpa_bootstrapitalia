{if $attribute.has_content}

	{def $view_nodes = array()}
	
	{if array(1,2)|contains($attribute.class_content.view)}	
	    	<ul class="list-unstyled">
	{/if}    	
			{foreach $attribute.content as $role}
				
				{def $view_node = false()}

				{if array(1,3)|contains($attribute.class_content.view)}
					{foreach $role|attribute('person').content.relation_list as $item}	        
				        {set $view_node = fetch(content, node, hash(node_id, $item.node_id))}
				        {break}      
				    {/foreach}
				{elseif array(2,4)|contains($attribute.class_content.view)}
					{foreach $role|attribute('for_entity').content.relation_list as $item}	        
				        {set $view_node = fetch(content, node, hash(node_id, $item.node_id))}
				        {break}      
				    {/foreach}
				{/if}

				{if $view_node} 
					{set $view_nodes = $view_nodes|append($view_node)}
				{/if}				
				
				{if array(1,2)|contains($attribute.class_content.view)}
				<li>	            
		            {$role|attribute('role').content.keyword_string} 
		            {if $view_node} presso
		            {def $openpa_view_node = object_handler($view_node)}
		            <a href="{$openpa_view_node.content_link.full_link}"
					   title="Link a {$view_node.name|wash()}">
					    	{$view_node.name|wash()}
				    	</span>			    	
					</a>				
					{undef $openpa_view_node}
					{/if}	
	        	</li>
	        	{/if}
		      
				{undef $view_node}

			{/foreach}
	{if array(1,2)|contains($attribute.class_content.view)}
			</ul>
	{/if}

	{if array(3,4)|contains($attribute.class_content.view)}
	    <div class="card-wrapper card-teaser-wrapper" style="min-width:49%">
		    {foreach $view_nodes as $child }
	            {node_view_gui content_node=$child view=card_teaser show_icon=true() image_class=widemedium}
	        {/foreach}
        </div>
	{/if}

	{undef $view_nodes}
{/if}