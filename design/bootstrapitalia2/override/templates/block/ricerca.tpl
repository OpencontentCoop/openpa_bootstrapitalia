{def $background_image = false()}
{if and(is_set($block.custom_attributes.image), $block.custom_attributes.image|ne(''))}
    {def $image = fetch(content, node, hash(node_id, $block.custom_attributes.image))}
    {if and($image, $image.class_identifier|eq('image'), $image|has_attribute('image'))}
        {set $background_image = $image|attribute('image').content.original.full_path|ezroot(no)}
    {/if}
    {undef $image}
{/if}
{def $logo_image = false()}
{def $logo_link = false()}
{def $logo_alt = false()}
{if and(is_set($block.custom_attributes.logo), $block.custom_attributes.logo|ne(''))}
    {def $logo = fetch(content, node, hash(node_id, $block.custom_attributes.logo))}
    {if and($logo, $logo.class_identifier|eq('banner'), $logo|has_attribute('image'))}
        {set $logo_image = $logo|attribute('image').content.original.full_path|ezroot(no)}
        {set $logo_link = object_handler($logo).content_link.full_link}
        {set $logo_alt = $logo.name|wash()}
    {/if}
    {undef $logo}
{/if}
<div class="section section-muted p-0 py-5 useful-links-section position-relative">
    {if $background_image}
      <div class="block-bg h-100 {if $logo_image}overlay-wrapper{/if}">
        {include name="bg" uri='design:atoms/background-image.tpl' url=$background_image}
        {if $logo_image}
          <div class="overlay-panel overlay-panel-fullheight oc-overlay-gradient-bottom-md-right"></div>
        {/if}
      </div>
    {/if}
    <div class="container{if and(count($block.valid_nodes)|eq(0), $background_image)} py-5{/if}">
        <div class="row d-flex justify-content-center">
            <div class="col-12 col-lg-6">
                <div class="cmp-input-search">
                    <form action="{'/content/search/'|ezurl(no)}" method="get" class="form-group autocomplete-wrapper{if $background_image|not()} mb-2 mb-lg-4{/if}">
                        <div class="input-group">
                            <label for="{$block.id}-search" class="visually-hidden">{'Search'|i18n('design/plain/layout')}</label>
                            <input type="search" class="autocomplete form-control" placeholder="{$block.name|wash()}" id="{$block.id}-search" name="SearchText" data-bs-autocomplete="[]" data-focus-mouse="false">

                            <div class="input-group-append">
                                <button class="btn btn-primary" type="submit" id="button-3">{'Search'|i18n('design/plain/layout')}</button>
                            </div>

                            <span class="autocomplete-icon" aria-hidden="true">
                                {display_icon('it-search', 'svg', 'icon icon-sm icon-primary', 'Search'|i18n('design/plain/layout'))}
                            </span>
                        </div>
                    </form>
                </div>
                {if count($block.valid_nodes)|gt(0)}
                    {if and(is_set($block.custom_attributes.show_links_as_buttons),$block.custom_attributes.show_links_as_buttons|eq(1))}
                        <div class="position-relative">
                        {foreach $block.valid_nodes as $valid_node}
                            {node_view_gui content_node=$valid_node a_class="btn btn-primary px-3 py-2 mt-3 text-nowrap" view=text_linked ignore_data_element=true()}
                        {/foreach}
                        </div>
                    {else}
                    <div class="link-list-wrapper bg-white p-3 position-relative">
                        <div class="link-list-heading text-uppercase mb-3 ps-0">{'Useful links'|i18n( 'bootstrapitalia' )}</div>
                        <ul class="link-list" role="list">
                            {foreach $block.valid_nodes as $valid_node}
                            <li role="listitem">
                                {node_view_gui content_node=$valid_node a_class="list-item mb-3 active ps-0" span_class="text-button-normal" view=text_linked show_icon=true()}
                            </li>
                            {/foreach}
                        </ul>
                    </div>
                {/if}
                {/if}
            </div>
            {if $logo_image}
              <div class="col-12 col-lg-6 d-flex justify-content-center align-items-center justify-content-lg-end" style="z-index: 1;">
                <div class="mt-5 mt-lg-0 text-lg-center">
                  <a href="{$logo_link}" target="_blank" rel="noopener" title="{$logo_alt}">
                    <img src="{$logo_image}"
                      alt="{$logo_alt}"
                      class="img-fluid"
                      style="max-width: 100%; max-height: 70px;"/>
                  </a>
                </div>
              </div>
            {/if}
        </div>
    </div>
</div>