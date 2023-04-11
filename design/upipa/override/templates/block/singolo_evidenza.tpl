{def $valid_node = $block.valid_nodes[0]
     $image_attribute = $valid_node|attribute('image')
     $image = false()}

{if and($image_attribute, $image_attribute.content['agid_wide_carousel'])}
  {set $image = $image_attribute.content['agid_wide_carousel'].url|ezroot(no)}
{/if}

{def $openpa_valid_node = object_handler($valid_node)}
<div class="Hero openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}" style="background-image:url({$image});">

  {if $image}
      <div class="Hero-image u-sm-hidden u-md-hidden u-lg-hidden">
        {*attribute_view_gui attribute=$image_attribute image_class="agid_panel" fluid=$fluid*}
          <a href="{$openpa_valid_node.content_link.full_link}" aria-hidden="true" tabindex="-1">
              <img src="{$image}"
                   alt="Immagine decorativa per il contenuto {$valid_node.name|wash()}"
                   class="u-sizeFull"
                   role="presentation" />
          </a>
      </div>
  {/if}

    <div class="Hero-content">
      {if array('link','banner')|contains($valid_node.class_identifier)|not()}
        <p class="u-padding-r-bottom u-padding-r-top u-text-r-xs u-xs-hidden">
          <a href="{$valid_node.parent.url_alias|ezurl(no)}" class="u-textClean u-color-60 u-text-h4"><span class="Dot u-background-60"></span>{$valid_node.parent.name|wash()}</a>
        </p>
      {/if}
      <h2 class="u-text-h2"><a href="{$openpa_valid_node.content_link.full_link}" class="u-color-95 u-textClean">{$valid_node.name|wash()}</a></h2>
      {if $valid_node|has_abstract()}
        <p class="u-padding-r-bottom u-padding-r-top u-text-p u-margin-r-bottom">{$valid_node|abstract()|oc_shorten(150)}</p>
      {/if}
    </div>
</div>
{undef $openpa_valid_node}
