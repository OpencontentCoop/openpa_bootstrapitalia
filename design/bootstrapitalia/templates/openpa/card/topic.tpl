{set_defaults(hash(
    'show_icon', true(),
    'image_class', 'large',
    'view_variation', ''    
))}

{def $has_media = false()}
{if $node|has_attribute('image')}
    {set $has_media = true()}
{/if}

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

            {include uri='design:openpa/card/parts/abstract.tpl'}  

            <a class="read-more" href="{$openpa.content_link.full_link}">
                <span class="text">{'Explore topic'|i18n('bootstrapitalia')}</span>
                {display_icon('it-arrow-right', 'svg', 'icon')}
            </a>

        </div>
    </div>
</div>
{unset_defaults(array('show_icon', 'image_class', 'view_variation'))}