{if $openpa.content_infocollection.is_information_collector}
    <form enctype="multipart/form-data" action="{"/content/action"|ezurl(no)}" method="post">
        <div class="content-infocollection">
            {include name=Validation uri='design:content/collectedinfo_validation.tpl'
                     class='message-warning text-sans-serif'
                     validation=$validation
                     collection_attributes=$collection_attributes}

            {foreach $openpa.content_infocollection.attributes as $attribute_handler}
                {def $contentclass_attribute = $attribute_handler.contentclass_attribute}
                <div class="form-group mb-3{if $contentclass_attribute.category|eq('hidden')} hide{/if}">
                    {if $contentclass_attribute.data_type_string|ne('ezboolean')}
                    <h6 class="text-sans-serif">
                        {$contentclass_attribute.name|wash()}
                        {if $contentclass_attribute.description}
                            <small class="text-muted mb-1 d-block">{first_set( $contentclass_attribute.descriptionList[$content_language], $contentclass_attribute.description)|wash}</small>
                        {/if}
                    </h6>
                    {/if}
                    {attribute_view_gui attribute=$attribute_handler.contentobject_attribute html_class='form-control border'}
                </div>
                {undef $contentclass_attribute}
            {/foreach}

            <div class="content-action clearfix">
                <input type="submit" class="btn btn-primary btn-lg pull-right text-sans-serif" name="ActionCollectInformation" value="{'Send'|i18n('bootstrapitalia')}" />
                <input type="hidden" name="ContentNodeID" value="{$node.node_id}" />
                <input type="hidden" name="ContentObjectID" value="{$node.object.id}" />
                <input type="hidden" name="ViewMode" value="full" />
            </div>
        </div>
    </form>
{/if}