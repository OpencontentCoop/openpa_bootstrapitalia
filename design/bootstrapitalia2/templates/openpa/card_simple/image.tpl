{set_defaults(hash('image_class', 'imagelargeoverlay', 'view_variation', ''))}
<div class="it-grid-item-wrapper it-grid-item-overlay {$node|access_style}">
    <a data-element="{$openpa.data_element.value|wash()}" class="" title="{$node.name|wash()}" {if $view_variation|eq('gallery')}data-gallery href={$node|attribute('image').content.reference.url|ezroot}{else}href="{$openpa.content_link.full_link}"{/if}>
        <div class="img-responsive-wrapper bg-dark">
            <div class="img-responsive">
                <div class="img-wrapper">
                    {if $node|has_attribute('image')}
                        {def $image = $node|attribute('image')}
                        {attribute_view_gui attribute=$image
                                            image_css_class=concat($image_css_class, " ", image_class_and_style($image.content.original.width, $image.content.original.height, 'card').css_class)
                                            inline_style= image_class_and_style($image.content.original.width, $image.content.original.height, 'card').inline_style}
                        {undef $image}
                    {else}
                        <div class="bg-dark" style="width:{rand(300,400)}px;height:{rand(300,400)}px"></div>
                    {/if}
                </div>
            </div>
        </div>
        <span class="it-griditem-text-wrapper">
            {*def $class = ''
                 $count = $node.name|count_chars()}
            {if $count|gt(40)}
               {set $class = 'h6'}
            {elseif $count|gt(30)}
                {set $class = 'h5'}
            {elseif $count|gt(20)}
                {set $class = 'h4'}
            {/if}
            <h3 class="{$class}">{$node.name|wash()}</h3>
            {undef $count $class*}
            <h3 style="hyphens: auto;">{$node.name|wash()}</h3>
      </span>
    </a>
    {if and($view_variation|eq('gallery'), $node.can_edit)}
        <a style="z-index: 10;right: 0;left: auto;bottom: 0" class="position-absolute p-1" href="{$node.url_alias|ezurl(no)}">
            <span class="fa-stack">
              <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
              <i aria-hidden="true" class="fa fa-wrench fa-stack-1x fa-inverse"></i>
            </span>
        </a>
    {elseif and($openpa.content_link.is_node_link|not(), $node.can_edit)}
        <a style="z-index: 10;right: 0;left: auto;bottom: 0" class="position-absolute p-1" href="{$node.url_alias|ezurl(no)}">
            <span class="fa-stack">
              <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
              <i aria-hidden="true" class="fa fa-wrench fa-stack-1x fa-inverse"></i>
            </span>
        </a>
    {/if}
</div>
{unset_defaults(array('image_class', 'view_variation'))}
