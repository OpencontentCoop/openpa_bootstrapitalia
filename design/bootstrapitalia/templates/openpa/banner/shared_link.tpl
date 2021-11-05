<div class="position-relative">
    <a data-shared_link="{$node.contentobject_id}" data-shared_link_view="banner" data-object_id="{$node.contentobject_id}" href="{$openpa.content_link.full_link}"
       class="shared_link-banner banner {$view_variation} {$node|access_style}">
        <div class="banner-icon">
            <svg class="icon">
                {if $openpa.content_icon.icon}
                    {display_icon($openpa.content_icon.icon.icon_text, 'svg', 'icon')}
                {/if}
            </svg>
            <span></span>
        </div>
        <div class="banner-text">
            <h4>
                {$node.name|wash()}
                {include uri='design:parts/card_title_suffix.tpl'}
            </h4>
        </div>
    </a>
    <a style="z-index: 10;right: 0;left: auto;bottom: 0" class="position-absolute p-1" href="{$node.url_alias|ezurl(no)}">
        <span class="fa-stack">
          <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
          <i aria-hidden="true" class="fa fa-wrench fa-stack-1x fa-inverse"></i>
        </span>
    </a>
</div>
