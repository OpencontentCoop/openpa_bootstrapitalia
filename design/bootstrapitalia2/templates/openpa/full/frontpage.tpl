{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'has_sidemenu', false() )}

{def $current_view_tag = $openpa.content_tag_menu.current_view_tag}
{def $has_layout = cond(and($current_view_tag|not(), $node|has_attribute('layout')), true(), false())}
{def $blocks = cond($has_layout, parse_layout_blocks($node|attribute('layout').content.zones), false())}
{def $first_block_has_bg = cond(and($has_layout, is_set($blocks.first.has_bg), $blocks.first.has_bg), true(), false())}
{def $last_block_has_bg = cond(and($has_layout, is_set($blocks.last.has_bg), $blocks.last.has_bg), true(), false())}

{if $openpa.content_tag_menu.has_tag_menu}
    {if $openpa.content_tag_menu.current_view_tag}
        {ezpagedata_set( 'current_view_tag_keyword', $openpa.content_tag_menu.current_view_tag.keyword )}
        {ezpagedata_set( 'view_tag_root_node_url', $openpa.content_tag_menu.tag_menu_root_node.url_alias )}
    {/if}
{/if}

<div class="container">
    <div class="row justify-content-center{if $first_block_has_bg|not()} row-shadow{/if}">
        <div class="col-12 col-lg-10">
            <div class="cmp-hero">
                <section class="it-hero-wrapper bg-white align-items-start">
                    <div class="it-hero-text-wrapper pt-0 ps-0 pb-4 pb-lg-60">
                        <h1 class="text-black hero-title" data-element="page-name">
                            {if $current_view_tag}
                                {$current_view_tag.keyword|wash()}
                            {else}
                                {$node.name|wash()}
                            {/if}
                        </h1>
                        <div class="hero-text">
                            {if $current_view_tag|not()}
                                {include uri='design:openpa/full/parts/main_attributes.tpl'}
                            {else}
                                {tag_description($current_view_tag.id, ezini('RegionalSettings', 'Locale'))|wash()|nl2br}
                            {/if}
                        </div>
                    </div>
                </section>
            </div>
        </div>
    </div>
</div>

{if and($current_view_tag|not(), $node|has_attribute('layout'))}
    {attribute_view_gui attribute=$node|attribute('layout')}
{/if}

{node_view_gui content_node=$node view=children view_parameters=$view_parameters view_variation=cond(or($first_block_has_bg|not(), $last_block_has_bg, $blocks|not()), 'py-5', 'pb-5')}
