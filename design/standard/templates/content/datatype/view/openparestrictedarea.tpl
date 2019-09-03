{def $user_id_list = $attribute.content}
{if count($user_id_list)}
<ul class="list-unstyled">
{foreach $user_id_list as $user_id}	
    <li>
    	{fetch(content,object,hash(object_id, $user_id)).name|wash()}
    </li>    
{/foreach}
</ul>
{/if}