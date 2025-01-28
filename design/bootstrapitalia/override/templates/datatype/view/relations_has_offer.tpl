{def $node_list = array()}
{if $attribute.has_content}
    {foreach $attribute.content.relation_list as $relation_item}
        {if $relation_item.in_trash|not()}
            {def $content_object = fetch( content, object, hash( object_id, $relation_item.contentobject_id ) )}
            {if $content_object.can_read}
                {set $node_list = $node_list|append($content_object.main_node)}
            {/if}
            {undef $content_object}
        {/if}
    {/foreach}
{/if}

{if count($node_list)|gt(0)}  
    {foreach $node_list as $child }
        <div class="font-sans-serif card card-teaser card-teaser-info rounded shadow-sm p-3 card-teaser-info-width mt-0 mb-3">
            <div class="card-body">              
                {def $currency = $child|attribute('has_currency').content.keyword_string}
                <h5>
                    {if $child|has_attribute('has_eligible_user')}
                    <span class="category-top">{$child|attribute('has_eligible_user').content.keywords|implode(' ')}</span>
                    {/if}
                    {if $child|attribute('has_price_specification').data_float|int()|eq(0)}
                      <div class="card-title big-heading">{'FREE'|i18n('bootstrapitalia')}</div>
                    {else}
                      <div class="card-title big-heading">{if $currency|eq('Euro')}€{else}{$currency|wash()}{/if}
                      {$child|attribute('has_price_specification').content|wash()}
                      </div>
                    {/if}
                </h5>
                {undef $currency}
                <p class="mt-4">{$child|attribute('description').content|wash()}</p>
                {if $child|has_attribute('note')}
                    {attribute_view_gui attribute=$child|attribute('note')}
                {/if}
            </div>
      </div>

    {/foreach}   
{/if}

{undef $node_list}
