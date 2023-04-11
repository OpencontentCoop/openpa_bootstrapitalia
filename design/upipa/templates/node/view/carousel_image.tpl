<div class="openpa-panel openpa-carousel openpa-carousel_image {$node|access_style} Card u-color-grey-30">

    {if $node|has_attribute('image')}
        <div class="openpa-panel-image">
            <img src="{$node|attribute('image').content['agid_panel'].full_path|ezroot(no)}"
                 alt="Immagine decorativa per il contenuto {$node.name|wash()}"
                 class="u-sizeFull"
                 role="presentation" />
        </div>
        <div class="overlay">
            <h3><a href="{$node.url_alias|ezurl(no)}">{$node.name|wash}</a></h3>
        </div>
    {/if}
</div>
