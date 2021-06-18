{default $view_parameters            = array()
         $attribute_categorys        = ezini( 'ClassAttributeSettings', 'CategoryList', 'content.ini' )
         $attribute_default_category = ezini( 'ClassAttributeSettings', 'DefaultCategory', 'content.ini' )}

{def $count = 0}
{foreach $content_attributes_grouped_data_map as $attribute_group => $content_attributes_grouped}
    {if $attribute_group|ne('hidden')}
        {set $count = $count|inc()}
    {/if}
{/foreach}

{if $count|gt(1)}
    {set $count = 0}
    <div class="nav-tabs-hidescroll">
    <ul class="nav nav-tabs">
        {set $count = 0}
        {foreach $content_attributes_grouped_data_map as $attribute_group => $content_attributes_grouped}
            {if $attribute_group|ne('hidden')}
                <li class="nav-item">
                    <a class="nav-link{if $attribute_group|eq($attribute_default_category)} active{/if}" data-toggle="tab"
                       href="#attribute-group-{$attribute_group}">{$attribute_categorys[$attribute_group]}</a>
                </li>
                {set $count = $count|inc()}
            {/if}
        {/foreach}
        {*<li class="nav-item ml-auto">
            <a class="nav-link" data-toggle="tab"
               href="#contentactions">{'General information'|i18n( 'design/admin/content/edit_attribute')}</a>
        </li>*}
    </ul>
    </div>
{/if}

{def $attribute_style = 'bg-light'}
<div class="tab-content">
    {set $count = 0}
    {def $has_active = false()}
    {foreach $content_attributes_grouped_data_map as $attribute_group => $content_attributes_grouped}
        <div class="position-relative clearfix attribute-edit tab-pane{if and($has_active|not(),$attribute_group|eq($attribute_default_category))} active{set $has_active = true()}{/if} p-2 mt-2" id="attribute-group-{$attribute_group}"{if $attribute_group|eq('hidden')} style="display: none !important;"{/if}>
            {set $count = $count|inc()}
            {set $attribute_style = 'bg-light'}
            {foreach $content_attributes_grouped as $attribute_identifier => $attribute}
                {if $attribute_style|eq('bg-light')}{set $attribute_style = ''}{else}{set $attribute_style = 'bg-light'}{/if}

                {def $contentclass_attribute = $attribute.contentclass_attribute}
                <div id="edit-{$attribute_identifier}" class="anchor-offset row {$attribute_style} p-3 mb-4 ezcca-edit-datatype-{$attribute.data_type_string} ezcca-edit-{$attribute_identifier}{if $attribute.is_required|not()} attribute-not-required{/if}">
                    {* Show view GUI if we can't edit, otherwise: show edit GUI. *}
                    {if and( eq( $attribute.can_translate, 0 ), ne( $object.initial_language_code, $attribute.language_code ) )}
                        <div class="col-md-3">
                            <h6>
                                {first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}
                                {if $attribute.can_translate|not}
                                    <span class="nontranslatable">({'not translatable'|i18n( 'design/admin/content/edit_attribute' )})</span>
                                {/if}:
                                {if $contentclass_attribute.description}
                                    <small class="form-text text-muted mb-1">{first_set( $contentclass_attribute.descriptionList[$content_language], $contentclass_attribute.description)|wash}</small>
                                {/if}
                            </h6>
                        </div>
                        <div class="col-md-9">
                            {if $is_translating_content}
                                <div class="original">
                                    {attribute_view_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters}
                                    <input type="hidden" name="ContentObjectAttribute_id[]" value="{$attribute.id}"/>
                                </div>
                            {else}
                                {attribute_view_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters}
                                <input type="hidden" name="ContentObjectAttribute_id[]" value="{$attribute.id}"/>
                            {/if}
                        </div>
                    {else}
                        {if $is_translating_content}
                            <div class="col-md-3">
                                <h6{if $attribute.has_validation_error} class="text-danger"{/if}>
                                    {first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}
                                    {if $attribute.is_required}
                                        <span class="required" title="{'required'|i18n( 'design/admin/content/edit_attribute' )}">*</span>{/if}
                                    {if $attribute.is_information_collector}
                                        <span class="collector">({'information collector'|i18n( 'design/admin/content/edit_attribute' )})</span>
                                    {/if}
                                    {if $contentclass_attribute.description}
                                        <small class="form-text text-muted mb-1">{first_set( $contentclass_attribute.descriptionList[$content_language], $contentclass_attribute.description)|wash}</small>
                                    {/if}
                                </h6>
                            </div>
                            <div class="col-md-9">
                                <div class="card bg-light mb-2">
                                    <div class="card-body">
                                        {attribute_view_gui attribute_base=$attribute_base attribute=$from_content_attributes_grouped_data_map[$attribute_group][$attribute_identifier] view_parameters=$view_parameters image_class=medium}
                                    </div>
                                </div>
                                <div>
                                    {if $attribute.display_info.edit.grouped_input}
                                        <fieldset>
                                            {attribute_edit_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters html_class='form-control'}
                                            <input type="hidden" name="ContentObjectAttribute_id[]" value="{$attribute.id}"/>
                                        </fieldset>
                                    {else}
                                        {attribute_edit_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters html_class='form-control'}
                                        <input type="hidden" name="ContentObjectAttribute_id[]" value="{$attribute.id}"/>
                                    {/if}
                                </div>
                            </div>
                        {else}
                            {if $attribute.display_info.edit.grouped_input}
                                <div class="col-md-3">
                                    <h6{if $attribute.has_validation_error} class="text-danger"{/if}>
                                        {first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}
                                        {if $attribute.is_required}
                                        <span class="required" title="{'required'|i18n( 'design/admin/content/edit_attribute' )}">*</span>{/if}
                                        {if $attribute.is_information_collector}
                                            <span class="collector">({'information collector'|i18n( 'design/admin/content/edit_attribute' )})</span>
                                        {/if}
                                    </h6>
                                </div>
                                <div class="col-md-9">
                                    {if $contentclass_attribute.description}
                                        <small class="form-text text-muted mb-1">{first_set( $contentclass_attribute.descriptionList[$content_language], $contentclass_attribute.description)|wash}</small>
                                    {/if}
                                    {if array('ezimage', 'ezbinaryfile', 'ocmultibinary')|contains($contentclass_attribute.data_type_string)}
                                    <small class="form-text text-muted mb-1">
                                        {'Max file size'|i18n( 'design/standard/class/datatype' )}: {$contentclass_attribute.data_int1|max_upload_size()} MB
                                    </small>
                                    {/if}
                                    {attribute_edit_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters html_class='form-control'}
                                    <input type="hidden" name="ContentObjectAttribute_id[]" value="{$attribute.id}"/>
                                </div>
                            {else}
                                <div class="col-md-3">
                                    <h6{if $attribute.has_validation_error} class="text-danger"{/if}>
                                        {first_set( $contentclass_attribute.nameList[$content_language], $contentclass_attribute.name )|wash}
                                        {if $attribute.is_required}
                                            <span class="required" title="{'required'|i18n( 'design/admin/content/edit_attribute' )}">*</span>
                                        {/if}
                                        {if $attribute.is_information_collector}
                                            <span class="collector">({'information collector'|i18n( 'design/admin/content/edit_attribute' )})</span>
                                        {/if}
                                    </h6>
                                </div>
                                <div class="col-md-9">
                                    {if $contentclass_attribute.description}
                                        <small class="form-text text-muted mb-1">{first_set( $contentclass_attribute.descriptionList[$content_language], $contentclass_attribute.description)|wash}</small>
                                    {/if}
                                    {if array('ezimage', 'ezbinaryfile', 'ocmultibinary')|contains($contentclass_attribute.data_type_string)}
                                        <small class="form-text text-muted mb-1">
                                            {'Max file size'|i18n( 'design/standard/class/datatype' )}: {$contentclass_attribute.data_int1|max_upload_size()} MB
                                        </small>
                                    {/if}
                                    {attribute_edit_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters html_class='form-control'}
                                    <input type="hidden" name="ContentObjectAttribute_id[]" value="{$attribute.id}"/>
                                </div>
                            {/if}
                        {/if}
                    {/if}
                </div>
                {undef $contentclass_attribute}
            {/foreach}
        </div>
    {/foreach}
    {*<div class="clearfix attribute-edit tab-pane" id="contentactions">
        {include uri="design:content/edit_right_menu.tpl"}
    </div>*}
</div>