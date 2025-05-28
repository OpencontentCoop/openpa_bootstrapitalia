{foreach ezini( $attribute.block.type, 'FetchParameters', 'block.ini' ) as $fetch_parameter => $value}
    {if eq( $fetch_parameter, 'Source' )}
        <div class="row my-3">
            <label class="col-12 col-form-label font-weight-bold">{'Current source:'|i18n( 'design/standard/block/edit' )}</label>
            <div class="col-12">
                <input id="block-fetch-parameter-choose-source-{$attribute.block_id}"
                       class="btn-secondary btn py-1 px-2 btn-xs block-control"
                       name="CustomActionButton[{$attribute.attribute.id}_new_source_browse-{$attribute.zone_id}-{$attribute.block_id}]"
                       type="submit"
                       data-browsersubtree="1"
                       data-browserselectiontype="single"
                       value="{'Choose source'|i18n( 'design/standard/block/edit' )}"/>
                {if is_set( $fetch_params['Source'] )}
                    <ul>
                        {if is_array( $fetch_params['Source'] )}

                            {foreach $fetch_params['Source'] as $source}
                                {def $source_node = fetch( 'content', 'node', hash( 'node_id', $source ) )}
                                <li><a href="{$source_node.url_alias|ezurl(no)}" target="_blank"
                                       rel="noopener noreferrer"
                                       title="{$source_node.name|wash()} [{$source_node.object.content_class.name|wash()}]">{$source_node.name|wash()}</a>
                                </li>
                                {undef $source_node}
                            {/foreach}
                        {else}
                            {def $source_node = fetch( 'content', 'node', hash( 'node_id', $fetch_params['Source'] ) )}
                            <li><a href="{$source_node.url_alias|ezurl(no)}" target="_blank" rel="noopener noreferrer"
                                   title="{$source_node.name|wash()} [{$source_node.object.content_class.name|wash()}]">{$source_node.name|wash()}</a>
                            </li>
                            {undef $source_node}
                        {/if}
                    </ul>
                {/if}
            </div>
        </div>
    {else}
        <div class="row my-3">
            <label for="block-fetch-parameter-{$fetch_parameter}-{$block_id}"
                   class="col-12 col-form-label font-weight-bold">{$fetch_parameter}:</label>
            <div class="col-12">
                <input id="block-fetch-parameter-{$fetch_parameter}-{$attribute.block_id}" class="form-control w-100" type="text"
                       name="ContentObjectAttribute_ezpage_block_fetch_param_{$attribute.attribute.id}[{$attribute.zone_id}][{$attribute.block_id}][{$fetch_parameter}]"
                       value="{$fetch_params[$fetch_parameter]}"/>
            </div>
        </div>
    {/if}
{/foreach}
