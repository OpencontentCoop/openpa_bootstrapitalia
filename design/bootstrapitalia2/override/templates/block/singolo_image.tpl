{def $valid_node = $block.valid_nodes[0]}
{if and($valid_node, $valid_node|has_attribute('image'))}
    {def $image = $valid_node|attribute('image').object}
    {def $alt_text = $image.name}

    {if $image|has_attribute('author')}
        {set $alt_text = concat($alt_text, ' - ', $image|attribute('author').data_text)}
    {/if}
    {if $image|has_attribute('proprietary_license')}
        {set $alt_text = concat($alt_text, ' - ', $image|attribute('proprietary_license').data_text)}
    {elseif $image|has_attribute('license')}
        {set $alt_text = concat($alt_text, ' - ', $image|attribute('license').content.keyword_string)}
    {/if}

<div class="position-relative">
    <div class="bg-secondary" style="min-height: 200px">
        {attribute_view_gui attribute=$valid_node|attribute('image')
                            image_class='original'
                            inline_style='width:100%;min-height: 200px;object-fit: cover;'
                            alt_text=$alt_text|wash()}
    </div>
</div>
    {undef $alt_text $image}
{/if}