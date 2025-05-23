{ezpagedata_set( 'has_container', true() )}
{ezpagedata_set( 'has_sidemenu', false() )}

{def $parent = $node.parent}
{def $parent_openpa = object_handler($parent)}
{if and($parent_openpa.content_tag_menu.has_tag_menu, $node|has_attribute('type'))}
    {def $keyword = $node|attribute('type').content.tags[0].keyword|wash()}
    {ezpagedata_set( 'current_content_tagged_keyword', $keyword )}
    {ezpagedata_set( 'current_content_tagged_keyword_url', concat($parent.url_alias, '/(view)/', $keyword|urlencode()))}
    {undef $keyword}
{/if}

{def $show_main_channel = true()}
{if and($node|has_attribute('hide_main_channel'), $node|attribute('hide_main_channel').data_int|eq(1))}
    {set $show_main_channel = false()}
{/if}

<div class="container">
    <div class="row justify-content-center">
        <div class="col-12 col-lg-10">
            <div class="cmp-heading pb-3 pb-lg-4">
                <div class="row">
                    <div class="col-lg-8">
                        <h1 class="title-xxxlarge" data-element="service-title">{$node.name|wash()}</h1>
                        {include uri='design:openpa/full/parts/service_status.tpl'}
                        {include uri='design:openpa/full/parts/main_attributes.tpl'}
                        {if $show_main_channel}
                            {include uri='design:openpa/full/parts/service_access_button.tpl'}
                        {/if}
                    </div>
                    <div class="col-lg-3 offset-lg-1 mt-5 mt-lg-0">
                        {include uri='design:openpa/full/parts/actions.tpl'}
                        {include uri='design:openpa/full/parts/taxonomy.tpl'}
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>


{include uri='design:openpa/full/parts/main_image.tpl'}

<div class="container my-3">
{include uri='design:openpa/full/parts/attributes.tpl' object=$node.object}
</div>

{if $openpa['content_tree_related'].full.exclude|not()}
{include uri='design:openpa/full/parts/related.tpl' object=$node.object}
{/if}

{undef $parent $parent_openpa $show_main_channel}

{if can_check_remote_public_service()}
<script>
  var serviceIdentifier = "{$node|attribute('identifier').content}";
  var serviceId = {$node.contentobject_id};
  {literal}
  $.ez('ezjscbridge::check::' + serviceId + '::' + serviceIdentifier, null, function (response) {
    var inSync = response?.content?.is_status_in_sync === true;
    var isRemoteStatusActive = response?.content?.is_remote_status_active === true;
    if (!inSync && !isRemoteStatusActive) {
      $('[data-element="service-status"] span').text(response?.content?.remote_status_message || 'Servizio non attivo')
      $('[data-element="service-main-access"], ' +
        '[data-element="service-generic-access"] > [data-element="service-online-access"], ' +
        '[data-element="service-generic-access"] > [data-element="service-booking-access"], ' +
        '[data-element="service-generic-access"] >[data-element="service-generic-access"]').hide();
      $('#status-note-placeholder').show();
    }
  });
  {/literal}
</script>
{/if}