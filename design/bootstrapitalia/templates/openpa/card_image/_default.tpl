{set_defaults(hash('image_class', 'large', 'view_variation', ''))}
<div class="it-grid-item-wrapper it-grid-item-overlay {$node|access_style}">
    <a href="{$openpa.content_link.full_link}" class="">
        <div class="img-responsive-wrapper bg-dark">
            <div class="img-responsive">
                <div class="img-wrapper">
                    {if $node|has_attribute('image')}
                        {attribute_view_gui attribute=$node|attribute('image') image_class=$image_class}
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
            <h3>{$node.name|wash()}</h3>
      </span>
    </a>
</div>
{unset_defaults(array('image_class', 'view_variation'))}