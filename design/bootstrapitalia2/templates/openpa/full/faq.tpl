{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'built_in_app', 'faq' )}

{def $parent = $node.parent}
{if $parent.class_identifier|ne('faq_group')}
    {set $parent = false()}
{/if}

<section class="container">
    <div class="row">
        <div class="col-lg-8 px-lg-4 py-lg-2">
            <div class="card-wrapper card-space">
                <div class="card card-bg card-big">
                    <div class="card-body">
                        {if $openpa.content_icon.class_icon}
                            <div class="category-top">
                                {display_icon($openpa.content_icon.class_icon.icon_text, 'svg', 'icon')}
                                {if $parent}<a class="category" href="{$parent.url_alias|ezurl(no)}">{$parent.name|wash()}</a>{/if}
                            </div>
                        {/if}
                        <h2 class="card-title">{$node.name|wash()}</h2>
                        <div class="card-text">{attribute_view_gui attribute=$node|attribute('answer')}</div>
                        {if $parent}
                        <a class="read-more" href="{$parent.url_alias|ezurl(no)}">
                            <span class="text">{'Further details'|i18n('bootstrapitalia')}</span>
                            {display_icon('it-arrow-right', 'svg', 'icon', 'Read more'|i18n('bootstrapitalia'))}
                        </a>
                        {/if}
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-3 offset-lg-1">
            {include uri='design:openpa/full/parts/actions.tpl'}
            {include uri='design:openpa/full/parts/taxonomy.tpl'}
        </div>
    </div>
</section>
