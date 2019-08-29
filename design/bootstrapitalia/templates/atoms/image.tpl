{set_defaults( hash(
    'figure_wrapper', true(),
    'figure_class', 'figure',
    'image_class', 'imagefullwide',
    'fluid', true(),
    'image_css_class', 'figure-img img-fluid'
))}

{def $main_attributes = class_extra_parameters($node.object.class_identifier, 'table_view').main_image}
{foreach $main_attributes as $identifier}
    {if $node|has_attribute($identifier)}
        {if $node|attribute($identifier).data_type_string|eq('ezimage')}

                {def $image = $node|attribute($identifier)}

                {if $figure_wrapper}
                <figure class="figure">
                {/if}

                    {attribute_view_gui attribute=$image
                                        image_class=$image_class
                                        image_css_class=$image_css_class
                                        fluid=$fluid}

                {if $figure_wrapper}
                    <figcaption class="figure-caption text-center pt-3">
                        {def $object = $image.object}
                        {if $object|has_attribute('caption')}
                            {$object|attribute('caption').content.output.output_text|oc_shorten(200,'...')}
                        {elseif $image.content.alternative_text}
                            {$image.content.alternative_text}
                        {/if}

                        <small class="d-block" style="font-size:.8em">
                            {if $object|has_attribute('author')}
                                &copy; {attribute_view_gui attribute=$object|attribute('author')} - 
                            {/if}
                            {if $object|has_attribute('proprietary_license')}
                                {attribute_view_gui attribute=$object|attribute('proprietary_license')}
                            {elseif $object|has_attribute('license')}
                                {$object|attribute('license').content.keyword_string|wash()}
                            {/if}
                        </small>
                        {undef $object}
                    </figcaption>
                </figure>
                {/if}

                {undef $image}

        {elseif $node|attribute($identifier).data_type_string|eq('ezobjectrelationlist')}
            {foreach $node|attribute($identifier).content.relation_list as $item}                
                {include name="related_main_image" uri='design:openpa/full/parts/main_image.tpl' node=fetch(content,node, hash(node_id, $item.node_id))}
                {break}
            {/foreach}
        {/if}
        {break}
    {/if}
{/foreach}
{undef $main_attributes}

{unset_defaults(array(
    'figure_wrapper',
    'figure_class',
    'image_class',
    'fluid',
    'image_css_class'
))}