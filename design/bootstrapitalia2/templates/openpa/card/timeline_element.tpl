{set_defaults(hash('show_icon', false(), 'image_class', 'imagelargeoverlay', 'view_variation', ''))}

{if class_extra_parameters($node.object.class_identifier, 'line_view').show|contains('show_icon')}
    {set $show_icon = true()}
{/if}

{def $has_image = false()}
{foreach class_extra_parameters($node.object.class_identifier, 'table_view').main_image as $identifier}
    {if and($node|has_attribute($identifier), or($node|attribute($identifier).data_type_string|eq('ezimage'), $identifier|eq('image')))}
        {set $has_image = true()}
        {break}
    {/if}
{/foreach}

{def $has_media = false()}
{if $has_image}
    {set $has_media = true()}
{/if}

<div data-object_id="{$node.contentobject_id}"
  class="card-wrapper border border-light rounded shadow-sm pb-0 {if $has_media} cmp-list-card-img {/if}">
  <div class="card no-after rounded bg-white">
    <div class="g-2 g-md-0 flex-md-column">
      {if $node|has_attribute('image')}
        {def $image = $node|attribute('image')}
        {attribute_view_gui image_css_class=concat("rounded-top img-fluid img-responsive ", image_class_and_style($image.content.original.width, $image.content.original.height, 'card').css_class)
                            inline_style= image_class_and_style($image.content.original.width, $image.content.original.height, 'card').inline_style
                            attribute=$image
                            image_class=$image_class
                            context='card'
                            alt_text=$node.name}
        {undef $image}
      {/if}
      <div class="col-12">
        <div class="card-body pb-2">
          <h4 class="font-weight-bold">
            {$node.name|wash()}
          </h4>
          {if and($node|has_attribute('abstract'), $node|attribute('abstract').has_content)}
            <div class="richtext-wrapper text-secondary">
              {attribute_view_gui attribute=$node|attribute('abstract')}
            </div>
          {/if}
        </div>
      </div>
    </div>
  </div>
</div>

{undef $has_image}

{unset_defaults(array('show_icon', 'image_class', 'view_variation'))}
