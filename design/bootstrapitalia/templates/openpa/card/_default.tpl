{set_defaults(hash('show_icon', true()))}
{def $show_children = cond(and(is_set($body_content), $body_content|eq('last_children'), $node.children_count|gt(0)), true(), false())}

<div class="card-wrapper card-space">
    <div class="card card-bg{if $node|has_attribute('image')} card-img{/if}">

        {if and($node|has_attribute('image'), $show_children|not())}
            <div class="img-responsive-wrapper">
                <div class="img-responsive">
                    <div class="img-wrapper">
                        {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class}
                    </div>
                </div>
            </div>
        {/if}

        <div class="card-body card-body-alt">


            {if $show_icon}
                {if $openpa.content_icon.object_icon}
                    <div class="card-icon">
                        <svg class="icon"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#{$openpa.content_icon.object_icon.icon_text}"></use></svg>
                    </div>
                {elseif $openpa.content_icon.context_icon}
                    <div class="card-icon-sm">
                        <a href="{$openpa.content_icon.context_icon.node.url_alias|ezurl(no)}" title="Vai alla pagina: {$openpa.content_icon.context_icon.node.name|wash()}" >
                            <svg class="icon"><use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#{$openpa.content_icon.context_icon.icon_text}"></use></svg>
                            <span>{$openpa.content_icon.context_icon.node.name|wash()}</span>
                        </a>
                    </div>
                {/if}
            {/if}

            <h5 class="card-title{if or($openpa.content_icon.context_icon|not(), $openpa.content_icon.object_icon, $show_icon|not())} big-heading{/if}">
                <a href="{$openpa.content_link.full_link}" class="color-primary">
                    {$node.name|wash()}
                </a>
            </h5>

            {if $show_children}

                <div class="link-list-wrapper">
                    <ul class="link-list">
                    {foreach fetch(openpa, list, hash('parent_node_id', $node.node_id,
                                                      'class_filter_type', 'exclude',
                                                      'class_filter_array',openpaini( 'ExcludedClassesAsChild', 'FromFolder', array( 'image', 'infobox', 'global_layout' ) ),
                                                      'sort_by', $node.sort_array,
                                                      'limit', 4)) as $child}
                        <li>
                            {node_view_gui content_node=$child
                                           view=text_linked
                                           show_icon=true()
                                           a_class='list-item'
                                           text_wrap_start='<span>'
                                           text_wrap_end='</span>'}
                        </li>
                    {/foreach}
                    </ul>
                </div>

            {else}

                {$node|abstract()}

            {/if}

            {if $node|has_attribute('menu_name')}
            <a class="read-more read-more-color-500" href="{$openpa.content_link.full_link}">
                <span class="text">{$node|attribute('menu_name').content|wash()}</span>
                <svg class="icon">
                    <use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-arrow-right"></use>
                </svg>
            </a>
            {/if}

        </div>
    </div>
</div>
{undef $show_children}
{unset_defaults(array('show_icon'))}