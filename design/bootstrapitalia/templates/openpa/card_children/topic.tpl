{set_defaults(hash(
    'show_icon', true(),
    'image_class', 'large',
    'view_variation', '',
    'limit', 7
))}

{def $related_items = api_search(concat("class != 'homepage' and topics.id in [", $node.contentobject_id, '] sort [modified=>desc] limit ', $limit))}
{def $language = ezini('RegionalSettings', 'Locale')}

<div data-object_id="{$node.contentobject_id}" class="card-wrapper {if $view_variation|eq('big')}card-space{/if} {$node|access_style}">
    <div class="card {if $node|has_attribute('image')} card-img{/if} {if $view_variation|eq('big')}card-bg rounded shadow{/if}">

        <div class="card-body">

            {if $openpa.content_icon.icon}
                <div class="card-icon mb-3">
                    {display_icon($openpa.content_icon.icon.icon_text, 'svg', 'icon m-0')}
                </div>
            {/if}

            <h5 class="card-title big-heading">
                {$node.name|wash()}
            </h5>
            
            {if $related_items.totalCount|gt(0)}
                <div class="link-list-wrapper">
                    <ul class="link-list">
                    {foreach $related_items.searchHits as $item}
                        <li>       
                            {def $icon = class_extra_parameters($item.metadata.classIdentifier, 'bootstrapitalia_icon').icon}                 
                            <a class="d-flex" href="{concat('content/view/full/', $item.metadata.mainNodeId)|ezurl(no)}">
                                {if $icon}
                                    {display_icon($icon, 'svg', 'icon icon-sm mr-2')}
                                {/if}
                                <span style="flex:1">{$item.metadata.name[$language]|wash()}</span>
                                
                            </a>                        
                            {undef $icon}
                        </li>
                    {/foreach}
                    </ul>
                </div>
            {else}
                {include uri='design:openpa/card/parts/abstract.tpl'}
            {/if}

            <a class="read-more" href="{$openpa.content_link.full_link}">
                <span class="text">{'Explore topic'|i18n('bootstrapitalia')}</span>
                {display_icon('it-arrow-right', 'svg', 'icon')}
            </a>

        </div>
    </div>
</div>
{unset_defaults(array('show_icon', 'image_class', 'limit', 'view_variation'))}
{undef $related_items $language}