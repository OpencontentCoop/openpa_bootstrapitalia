<div class="card-wrapper card-space">
    <div class="card card-bg{if $node|has_attribute('image')} card-img{/if}">

        {if and($node|has_attribute('image'), is_set($body_content)|not())}
            <div class="img-responsive-wrapper">
                <div class="img-responsive">
                    <div class="img-wrapper">
                        {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class}
                    </div>
                </div>
            </div>
        {/if}

        <div class="card-body">
            <h5 class="card-title big-heading">{$node.name|wash()}</h5>

            {if and(is_set($body_content), $body_content|eq('last_children'))}

                <div class="link-list-wrapper">
                    <ul class="link-list">
                    {foreach fetch(openpa, list, hash('parent_node_id', $node.node_id,
                                                      'class_filter_type', 'exclude',
                                                      'class_filter_array',openpaini( 'ExcludedClassesAsChild', 'FromFolder', array( 'image', 'infobox', 'global_layout' ) ),
                                                      'sort_by', $node.sort_array,
                                                      'limit', 4)) as $child}
                        <li>
                            {node_view_gui content_node=$child view=text_linked a_class='list-item' text_wrap_start='<span>' text_wrap_end='</span>'}
                        </li>
                    {/foreach}
                    </ul>
                </div>

            {else}

                {$node|abstract()}

            {/if}

            <a class="read-more" href="{$openpa.content_link.full_link}">
                <span class="text">Leggi di più</span>
                <svg class="icon">
                    <use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-arrow-right"></use>
                </svg>
            </a>
        </div>
    </div>
</div>