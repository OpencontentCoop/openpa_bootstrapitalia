{def $summary_text = "Indice della pagina"
     $close_text = "Chiudi"}

{def $summary_items = array()}
{def $attribute_groups = class_extra_parameters($object.class_identifier, 'attribute_group')}
{if $attribute_groups.enabled}
    {foreach $attribute_groups.group_list as $slug => $name}
        {if count($attribute_groups[$slug])|gt(0)}
            {def $openpa_attributes = array()}
            {foreach $attribute_groups[$slug] as $attribute_identifier}
                {if and( $openpa[$attribute_identifier].full.exclude|not(), or($openpa[$attribute_identifier].has_content, $openpa[$attribute_identifier].full.show_empty))}
                    {set $openpa_attributes = $openpa_attributes|append($openpa[$attribute_identifier])}
                {/if}
            {/foreach}
            {if count($openpa_attributes)|gt(0)}
                {set $summary_items = $summary_items|append(
                    hash( 'slug', $slug, 'title', $name, 'attributes', $openpa_attributes, 'is_grouped', true() )
                )}
            {/if}
            {undef $openpa_attributes}
        {/if}
    {/foreach}
{else}
    {def $table_view = class_extra_parameters($object.class_identifier, 'table_view')}
    {foreach $table_view.show as $attribute_identifier}
        {if or($openpa[$attribute_identifier].has_content, $openpa[$attribute_identifier].full.show_empty)}
            {set $summary_items = $summary_items|append(
                hash( 'slug', $attribute_identifier, 'title', $openpa[$attribute_identifier].label, 'attributes', array($openpa[$attribute_identifier]), 'is_grouped', false() )
            )}
        {/if}
    {/foreach}
    {undef $table_view}
{/if}

{if count($summary_items)|gt(0)}
<div class="container">
    <div class="row row-top-border row-column-border">
        <aside class="col-lg-3 col-md-4">
            <div class="sticky-wrapper navbar-wrapper">
                <nav class="navbar it-navscroll-wrapper navbar-expand-lg">
                    <button class="custom-navbar-toggler" type="button" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation" data-target="#navbarNav">
                        <h3 class="no_toc m-0">{$summary_text|wash()}</h3>
                    </button>
                    <div class="navbar-collapsable" id="navbarNav">
                        <div class="overlay"></div>
                        <div class="close-div sr-only">
                            <button class="btn close-menu" type="button">
                                <span class="it-close"></span> {$close_text|wash()}
                            </button>
                        </div>
                        <a class="it-back-button" href="#">
                            <svg class="icon icon-sm icon-primary align-top">
                                <use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-chevron-left"></use>
                            </svg>
                            <span>{$close_text|wash()}</span>
                        </a>
                        <div class="menu-wrapper">
                            <div class="link-list-wrapper">
                                <h3 class="no_toc">{$summary_text|wash()}</h3>
                                <ul class="link-list">
                                    {foreach $summary_items as $index => $item}
                                        <li class="nav-item{if $index|eq(0)} active{/if}">
                                            <a class="nav-link{if $index|eq(0)} active{/if}" href="#{$item.slug|wash()}"><span>{$item.title|wash()}</span></a>
                                        </li>
                                    {/foreach}
                                </ul>
                            </div>
                        </div>
                    </div>
                </nav>
            </div>
        </aside>
        <section class="col-lg-9 col-md-8 pt8">
            {foreach $summary_items as $index => $item}
                <article id="{$item.slug|wash()}">
                    <h4>{$item.title|wash()}</h4>
                    {foreach $item.attributes as $openpa_attribute}

                        {if $openpa_attribute.full.highlight}
                        <div class="callout important">
                            <div class="callout-title">
                                <svg class="icon icon-primary"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-info-circle"></use></svg>
                                {if and($openpa_attribute.full.show_label, $openpa_attribute.full.collapse_label|not(), $item.is_grouped)}
                                    {$openpa_attribute.label|wash()}
                                {/if}
                            </div>
                        {elseif and($openpa_attribute.full.show_label, $item.is_grouped)}
                            {if $openpa_attribute.full.collapse_label|not()}
                                <h5>{$openpa_attribute.label|wash()}</h5>
                            {else}
                                <strong>{$openpa_attribute.label|wash()}</strong>
                            {/if}
                        {/if}

                        {if is_set($openpa_attribute.contentobject_attribute)}
                            {attribute_view_gui attribute=$openpa_attribute.contentobject_attribute
                                                image_class=medium
                                                relation_view_variation='banner-shadow border-left'
                                                relation_view=cond($openpa_attribute.full.show_link|not, 'list', 'banner')}
                        {else}
                            {include uri=$openpa_attribute.template}
                        {/if}

                        {if $openpa_attribute.full.highlight}
                        </div>
                        {/if}
                    {/foreach}
                </article>
            {/foreach}
        </section>
    </div>
</div>
{/if}