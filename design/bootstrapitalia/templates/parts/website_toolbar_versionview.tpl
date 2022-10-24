{def $custom_templates = ezini( 'CustomTemplateSettings', 'CustomTemplateList', 'websitetoolbar.ini' )
     $include_in_view = ezini( 'CustomTemplateSettings', 'IncludeInView', 'websitetoolbar.ini' )}

<form method="post" action={concat( 'content/versionview/', $object.id, '/', $version.version, '/', $language, '/', $from_language )|ezurl}>
<nav class="toolbar edit-toolbar" id="ezwt">
    <ul class="d-flex flex-nowrap border-bottom">

    <li class="publish-buttons">
    {if or( and( eq( $version.status, 0 ), $is_creator, $object.can_edit ),and( eq( $object.status, 2 ), $object.can_edit ) )}
        <input type="submit" class="btn btn-xs btn-success" name="EditButton" value="{'Edit'|i18n( 'design/standard/content/view/versionview' )}" />
        <input type="submit" class="btn btn-xs btn-success" name="PreviewPublishButton" value="{'Publish'|i18n( 'design/standard/content/view/versionview' )}" />
    {/if}
    </li>

    {if $object.versions|count|gt( 1 )}
        <li>
            <button class="btn" type="submit" name="VersionsButton" title="{'Manage versions'|i18n('design/standard/content/edit')}">
                <i aria-hidden="true" class="fa fa-history"></i>
                <span class="toolbar-label">{'Manage versions'|i18n('design/standard/content/edit')}</span>
            </button>
        </li>
    {/if}

    {* Custom templates inclusion *}
    {def $custom_view_templates = array()}
    {foreach $custom_templates as $custom_template}
        {if is_set( $include_in_view[$custom_template] )}
            {def $views = $include_in_view[$custom_template]|explode( ';' )}
            {if $views|contains( 'versionview' )}
                {set $custom_view_templates = $custom_view_templates|append( $custom_template )}
            {/if}
            {undef $views}
        {/if}
    {/foreach}

    {if $custom_view_templates}
        <li>
            <div class="dropdown">
                <button class="btn btn-dropdown dropdown-toggle toolbar-more" type="button" id="dropdownToolbar" data-toggle="dropdown" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    <i aria-hidden="true" class="fa fa-ellipsis-h"></i>
                    <span class="toolbar-label">Altro</span>
                </button>
                <div class="dropdown-menu" aria-labelledby="dropdownToolbar">
                    <div class="link-list-wrapper">
                        <ul class="link-list">
                        {foreach $custom_view_templates as $custom_template}
                            {include uri=concat( 'design:parts/websitetoolbar/', $custom_template, '.tpl' )}
                        {/foreach}
                        </ul>
                    </div>
                </div>
            </div>
        </li>
    {/if}

    </ul>
</nav>
</form>
{include uri='design:parts/websitetoolbar/floating_toolbar.tpl'}

