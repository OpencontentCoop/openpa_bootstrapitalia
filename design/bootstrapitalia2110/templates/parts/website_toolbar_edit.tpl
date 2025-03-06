{def $custom_templates = ezini( 'CustomTemplateSettings', 'CustomTemplateList', 'websitetoolbar.ini' )
     $include_in_view = ezini( 'CustomTemplateSettings', 'IncludeInView', 'websitetoolbar.ini' )}

<nav class="toolbar edit-toolbar" id="ezwt">
    <ul class="d-flex flex-nowrap border-bottom">

        <li>
            <div class="input-group">
                {def $edit_attribute_groups = edit_attribute_groups($class, $content_attributes)}
                <label for="ezwt-create" class="d-none">{'Jump to field'|i18n('bootstrapitalia')}</label>
                <select id="ezwt-create" class="custom-select" style="max-width: 200px">
                    <option>{'Jump to field'|i18n('bootstrapitalia')}</option>
                    {foreach $edit_attribute_groups.groups as $index => $attribute_group}
                        {if $attribute_group.show}
                        <optgroup label="{$attribute_group.label}">
                            {foreach $attribute_group.attributes as $attribute_identifier => $attribute}
                                <option data-group="{$attribute_group.identifier}" data-identifier="{$attribute_identifier}">{$attribute.contentclass_attribute.name|wash()}</option>
                            {/foreach}
                        </optgroup>
                        {/if}
                    {/foreach}
                </select>
            </div>
            {undef $edit_attribute_groups}
        </li>

        <li>
            <div class="form-check form-check-group pb-0 my-0 border-0" style="box-shadow:none">
                <div class="toggles">
                    <label for="OnlyRequired" class="mb-0 font-weight-normal" style="max-width: 100px;">
                        <input type="checkbox" id="OnlyRequired" value="1">
                        <span class="lever" style="float:none;display: inline-block;margin-bottom: 5px;"></span>
                        <span class="toolbar-label" style="font-size: .65em;">{'Display only required fields'|i18n( 'design/ocbootstrap/content/edit' )}</span>
                    </label>
                </div>
            </div>
        </li>

        {if openpaini('EditSettings','ModerationInToolbar', 'disabled')|eq('enabled')}
            {include uri='design:parts/websitetoolbar_edit/moderation.tpl' content_object=$object}
        {/if}

        {if ezini('ExtensionSettings','ActiveAccessExtensions')|contains('octranslate')}
            {include uri='design:parts/websitetoolbar_edit/translate.tpl' content_object=$object}
        {/if}

        <li class="publish-buttons">
            <input class="btn btn-xs btn-success" type="submit" name="PublishButton" value="{'Send for publishing'|i18n( 'design/ocbootstrap/content/edit' )}" title="{'Publish the contents of the draft that is being edited. The draft will become the published version of the object.'|i18n( 'design/standard/content/edit' )}" />
            <input class="btn btn-xs btn-warning" type="submit" name="StoreButton" value="{'Store draft'|i18n( 'design/ocbootstrap/content/edit' )}" title="{'Store the contents of the draft that is being edited and continue editing. Use this button to periodically save your work while editing.'|i18n( 'design/standard/content/edit' )}" />
            <input class="btn btn-xs btn-warning" type="submit" name="StoreExitButton" value="{'Store draft and exit'|i18n( 'design/ocbootstrap/content/edit' )}" title="{'Store the draft that is being edited and exit from edit mode. Use when you need to exit your work and return later to continue.'|i18n( 'design/standard/content/edit' )}" />
            <input class="btn btn-xs btn-dark" type="submit" name="DiscardButton" value="{'Discard draft'|i18n( 'design/ocbootstrap/content/edit' )}" onclick="return window.confirmDiscard ? confirmDiscard( '{'Are you sure you want to discard the draft?'|i18n( 'design/standard/content/edit' )|wash(javascript)}' ): true;" title="{'Discard the draft that is being edited. This will also remove the translations that belong to the draft (if any).'|i18n( 'design/standard/content/edit' ) }" />
        </li>

        <li>
            <button class="btn" type="submit" name="VersionsButton" title="{'Manage versions'|i18n('design/standard/content/edit')}">
                <i aria-hidden="true" class="fa fa-history"></i>
                <span class="toolbar-label">{'Manage versions'|i18n('design/standard/content/edit')}</span>
            </button>
        </li>

        <li>
            <button class="btn" type="submit" name="PreviewButton" title="{'Preview'|i18n('design/standard/content/edit')}">
                {display_icon('it-presentation', 'svg', 'icon icon-sm')}
                <span class="toolbar-label">{'Preview'|i18n('design/standard/content/edit')}</span>
            </button>
        </li>

        {def $append_translations = true()}
        {if and(count($object.languages)|eq(1), is_set($object.languages[$edit_language]))}
            {set $append_translations = false()}
        {/if}
        {if and($append_translations, $object.status|ne(0))}
        <li>
            <div class="input-group">
                <select name="FromLanguage" class="custom-select" style="max-width: 200px">
                        <option value=""{if $from_language|not} selected="selected"{/if}> {'Translate from'|i18n( 'design/standard/content/edit' )}</option>
                    {foreach $object.languages as $lang}
                        <option value="{$lang.locale}"{if $lang.locale|eq($from_language)} selected="selected"{/if}>
                            {$lang.name|wash}
                        </option>
                    {/foreach}
                </select>
                <div class="input-group-append">
                    <button class="btn btn-info" type="submit" name="FromLanguageButton" title="{'Translate'|i18n( 'design/standard/content/edit' )}">
                        {'Translate'|i18n( 'design/standard/content/edit' )}
                    </button>
                </div>
            </div>
        </li>
        {/if}

        {* Custom templates inclusion *}
        {def $custom_view_templates = array()}
        {foreach $custom_templates as $custom_template}
            {if is_set( $include_in_view[$custom_template] )}
                {def $views = $include_in_view[$custom_template]|explode( ';' )}
                {if $views|contains( 'edit' )}
                    {set $custom_view_templates = $custom_view_templates|append( $custom_template )}
                {/if}
                {undef $views}
            {/if}
        {/foreach}

        {if $custom_view_templates}
        <li>
            <div class="dropdown">
                <button class="btn btn-dropdown dropdown-toggle toolbar-more" type="button" id="dropdownToolbar" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
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

{include uri='design:parts/websitetoolbar/floating_toolbar.tpl'}
<script>{literal}
  $(document).ready(function () {
    var formEdit = $('form.edit');
    function appendCurrentaPagetoFormAction(hash) {
      var originalAction = formEdit.data('original_action');
      if (originalAction) {
        formEdit.attr('action', originalAction+hash);
      }
    }
    formEdit.find('[data-bs-toggle="tab"]').on('shown.bs.tab', function (event) {
      appendCurrentaPagetoFormAction($(this).attr('href'))
    })

    if(location.hash && location.hash.includes('attribute-group')){
      var triggerFirstTabEl = document.querySelector('[data-bs-target="' + location.hash + '"]')
      bootstrap.Tab.getOrCreateInstance(triggerFirstTabEl).show();
      appendCurrentaPagetoFormAction(location.hash);
    }
    function jumpTo(group,identifier){
      var triggerFirstTabEl = document.querySelector('[data-bs-target="#attribute-group-' + group + '"]')
      bootstrap.Tab.getOrCreateInstance(triggerFirstTabEl).show()
      $('html,body').animate({scrollTop: ($('#edit-' + identifier).offset().top - 100)}, 400);
      appendCurrentaPagetoFormAction('#attribute-group-' + group);
    }
    $('[data-invalid_identifier]').on('click', function (e){
      var elForm = $('[data-attribute_identifier="'+$(this).data('invalid_identifier')+'"]');
      jumpTo(elForm.data('attribute_group'), elForm.data('attribute_identifier'));
      e.preventDefault();
    })
    $('[data-jumpto_group]').on('click', function (e){
      jumpTo($(this).data('jumpto_group'), $(this).data('jumpto_attribute'));
      e.preventDefault();
    });
    $('select#ezwt-create').chosen({width: "300px !important"}).change(function (e) {
      var values = $(e.currentTarget).find('option:selected').data();
      jumpTo(values.group, values.identifier);
    });
    var showOnlyRequired = function () {
      if (toggleOnlyRequired.is(':checked')) {
        $('.attribute-not-required').addClass('hide');
      } else {
        $('.attribute-not-required').removeClass('hide');
      }
    }
    var toggleOnlyRequired = $('#OnlyRequired').on('change', function (e) {
      showOnlyRequired();
    });
    showOnlyRequired();
  });
{/literal}</script>
