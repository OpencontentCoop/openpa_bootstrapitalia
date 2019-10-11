{def $summary_text = 'Table of contents'|i18n('bootstrapitalia')
     $close_text = 'Close'|i18n('bootstrapitalia')}
{if is_set($show_all_attributes)|not()}
    {def $show_all_attributes = false()}
{/if}
{def $summary_items = array()}
{def $attribute_groups = class_extra_parameters($object.class_identifier, 'attribute_group')}

{if $show_all_attributes}
    {foreach $object.data_map as $attribute_identifier => $attribute}
        {if and($openpa[$attribute_identifier].has_content, $attribute.contentclass_attribute.category|ne('hidden'))}
            {set $summary_items = $summary_items|append(
                hash( 'slug', $attribute_identifier, 'title', $openpa[$attribute_identifier].label, 'attributes', array($openpa[$attribute_identifier]), 'is_grouped', false(), 'wrap', false() )
            )}
        {/if}
    {/foreach}
{elseif $attribute_groups.enabled}
    {foreach $attribute_groups.group_list as $slug => $name}
        {if count($attribute_groups[$slug])|gt(0)}
            {def $openpa_attributes = array()
                 $wrapped = true()}
            {foreach $attribute_groups[$slug] as $attribute_identifier}
                {if and( is_set($openpa[$attribute_identifier]), $openpa[$attribute_identifier].full.exclude|not(), or($openpa[$attribute_identifier].has_content, $openpa[$attribute_identifier].full.show_empty))}
                    {set $openpa_attributes = $openpa_attributes|append($openpa[$attribute_identifier])}
                    {if and($wrapped, $openpa[$attribute_identifier].full.show_link|not())}{set $wrapped = false()}{/if}
                    {if and($wrapped, $openpa[$attribute_identifier].full.show_label)}{set $wrapped = false()}{/if}
                {/if}
            {/foreach}
            {if count($openpa_attributes)|gt(0)}
                {set $summary_items = $summary_items|append(
                    hash( 'slug', $slug, 'title', $attribute_groups.current_translation[$slug], 'attributes', $openpa_attributes, 'is_grouped', true(), 'wrap', cond($wrapped, count($openpa_attributes)|gt(1),true(),false()) )
                )}
            {/if}
            {undef $openpa_attributes $wrapped}
        {/if}
    {/foreach}
{else}
    {def $table_view = class_extra_parameters($object.class_identifier, 'table_view')}
    {foreach $table_view.show as $attribute_identifier}
        {if or($openpa[$attribute_identifier].has_content, $openpa[$attribute_identifier].full.show_empty)}
            {set $summary_items = $summary_items|append(
                hash( 'slug', $attribute_identifier, 'title', $openpa[$attribute_identifier].label, 'attributes', array($openpa[$attribute_identifier]), 'is_grouped', false(), 'wrap', false() )
            )}
        {/if}
    {/foreach}
    {undef $table_view}
{/if}

{if count($summary_items)|gt(0)}
    <div class="row border-top row-column-border row-column-menu-left attribute-list">
        <aside class="col-lg-4">
            <div class="sticky-wrapper navbar-wrapper">
                <nav class="navbar it-navscroll-wrapper it-top-navscroll navbar-expand-lg">
                    <button class="custom-navbar-toggler" type="button" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation" data-target="#navbarNav">
                        <span class="it-list"></span> {$summary_text|wash()}
                    </button>
                    <div class="navbar-collapsable" id="navbarNav">
                        <div class="overlay"></div>
                        <div class="close-div sr-only">
                            <button class="btn close-menu" type="button">
                                <span class="it-close"></span> {$close_text|wash()}
                            </button>
                        </div>
                        <a class="it-back-button" href="#">
                            {display_icon('it-chevron-left', 'svg', 'icon icon-sm icon-primary align-top')}
                            <span>{$close_text|wash()}</span>
                        </a>
                        <div class="menu-wrapper">
                            <div class="link-list-wrapper menu-link-list">
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
        <section class="col-lg-8">
            {foreach $summary_items as $index => $item}
                <article id="{$item.slug|wash()}" class="it-page-section mb-2 anchor-offset" {*if $index|eq(0)} class="anchor-offset"{/if*}>
                    <h4>{$item.title|wash()}</h4>

                    {if $item.wrap}                    
                    <div class="card-wrapper card-teaser-wrapper card-teaser-embed">
                    {/if}

                    {foreach $item.attributes as $openpa_attribute}

                        {if $openpa_attribute.full.highlight}
                        <div class="callout important">
                            <div class="callout-title">
                                {display_icon('it-info-circle', 'svg', 'icon')}
                                {if and($openpa_attribute.full.show_label, $openpa_attribute.full.collapse_label|not(), $item.is_grouped)}
                                    {$openpa_attribute.label|wash()}
                                {/if}
                            </div>
                            <div class="text-serif small neutral-1-color-a7">
                        {elseif and($openpa_attribute.full.show_label, $item.is_grouped)}
                            {if $openpa_attribute.full.collapse_label|not()}
                                <h5 class="no_toc">{$openpa_attribute.label|wash()}</h5>
                            {else}
                                <h6 class="d-inline font-weight-bold">{$openpa_attribute.label|wash()}</h6>
                            {/if}
                        {/if}

                        {if is_set($openpa_attribute.contentobject_attribute)}
                            {attribute_view_gui attribute=$openpa_attribute.contentobject_attribute
                                                image_class=medium
                                                relation_view=cond($openpa_attribute.full.show_link|not, 'list', 'banner')
                                                relation_has_wrapper=$item.wrap
                                                show_link=$openpa_attribute.full.show_link
                                                tag_view="chip-lg mr-2"}
                        {else}
                            {include uri=$openpa_attribute.template}
                        {/if}

                        {if $openpa_attribute.full.highlight}
                            </div>
                        </div>
                        {/if}
                    {/foreach}

                    {if $item.wrap}
                    </div>
                    {/if}

                </article>
            {/foreach}
        </section>
    </div>
    <script>{literal}$(document).ready(function () {
        $('.menu-wrapper a.nav-link').on('click', function () {
            $(this).addClass('active')
                .parent().addClass('active')
                .parents('.menu-wrapper').find('.active').not(this).removeClass('active')
        })
    }){/literal}</script>
{/if}