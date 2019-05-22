{if $node|has_attribute( 'image' )}
    <section id="image">
        <figure>
            {attribute_view_gui attribute=$node|attribute( 'image' )
            image_class=imagefullwide
            image_css_class='of-cover of-md-contain'
            fluid=true()}
            {if $node|attribute( 'image' ).content.alternative_text}
                <figcaption>{$node|attribute( 'image' ).content.alternative_text}</figcaption>
            {/if}
        </figure>
    </section>
{/if}