<div class="mb-3">
    <h2>
        {'Do you confirm the publication of the content?'|i18n('ocbootstrap/confirmpublish')}
    </h2>

    {def $node = $version.temp_main_node}
    {foreach $version.data_map as $attribute}
        {if and($attribute.has_content, $attribute.contentclass_attribute.category|ne('hidden'))}
            <div class="row mb-3">
                <div class="col-md-4">
                    <strong>{$attribute.contentclass_attribute_name}</strong>
                </div>
                <div class="col-md-8">
                  <div class="{cond($attribute.data_type_string|eq('ezxmltext'), 'richtext-wrapper', '')}">
                    {attribute_view_gui attribute=$attribute show_newline=true() confirmpublish=true()}
                  </div>
                </div>
            </div>
        {/if}
    {/foreach}


    <div class="row">
        <div class="col-md-6 text-left">
            <a class="btn btn-dark"
               href="{concat('gdpr/confirmpublish/0/', $version.contentobject_id, '/', $version.version, '/', $language)|ezurl('no')}">
                {'I do not confirm'|i18n('ocbootstrap/confirmpublish')}
            </a>
        </div>
        <div class="col-md-6 text-right">
            <a class="btn btn-success"
               href="{concat('gdpr/confirmpublish/1/', $version.contentobject_id, '/', $version.version, '/', $language)|ezurl('no')}">
                {'I confirm the publication'|i18n('ocbootstrap/confirmpublish')}
            </a>
        </div>
    </div>
</div>
<style>
section, .section{ldelim}padding:5px{rdelim}
</style>