{set_defaults(hash(
    'image_class', 'small',
    'image_css_class', "float-left"
))}
<div class="d-flex align-items-stretch">
    {if $node|has_attribute('image')}
        <a class="mr-3" href="{$openpa.content_link.full_link}">
            {attribute_view_gui image_class=$image_class
                                attribute=$node|attribute('image')
                                href=false()
                                fluid=false()
                                alt_text=concat("Immagine decorativa per il contenuto ", $node.name|wash())}
        </a>
    {/if}
    <div>
        {$node|abstract()}
        <a class="read-more" href="{$openpa.content_link.full_link}">
            <span class="text">Leggi di più</span>
            <svg class="icon">
                <use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-arrow-right"></use>
            </svg>
        </a>
    </div>
</div>

{unset_defaults(array(
    'image_class',
    'image_css_class'
))}