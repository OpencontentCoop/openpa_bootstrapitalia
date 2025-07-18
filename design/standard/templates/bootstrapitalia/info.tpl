{ezpagedata_set( 'has_container', true() )}
{def $pagedata = openpapagedata()}

<div class="container mb-3">
    <h1 class="mb-4 h3">Gestioni contatti e informazioni generali</h1>

    {if is_set($message)}
        <div class="message-error">
            <p>{$message}</p>
        </div>
    {/if}

    {if $homepage}
        <form method="post" action="{'bootstrapitalia/info'|ezurl(no)}" enctype="multipart/form-data" class="form">
        {foreach $sections as $section}
            <div class="border border-light rounded p-3 mb-3">
                <h5>{$section.label}</h5>
                {foreach $section.contacts as $contact_identifier}
                    {def $contact = $contacts[$contact_identifier]}
                    <div class="row mb-3">
                        <label for="{$contact.identifier}" class="col-sm-3 col-form-label text-md-end">{$contact.label}</label>
                        <div class="col-sm-9">
                            <input type="text" name="Contacts[{$contact.label}]" class="form-control" id="{$contact.identifier}" value="{$contact.value}">
                        </div>
                    </div>
                    {undef $contact}
                {/foreach}
            </div>
        {/foreach}

        <div class="border border-light rounded p-3 mb-3">
            <h5>Logo</h5>
            <div class="row mb-3">
                <label for="Logo" class="col-sm-3 col-form-label">
                    {if $logo_url}
                        <img alt="{ezini('SiteSettings','SiteName')}"
                             width="82"
                             height="82"
                             class="bg-primary"
                             src="{$logo_url}" />
                    {/if}
                </label>
                <div class="col-sm-9">
                    <input type="file" name="Logo" class="form-control" id="Logo" value="">
                </div>
            </div>
        </div>

        <div class="border border-light rounded p-3 mb-3">
            <h5>Favicon</h5>
            <p class="form-text">La favicon viene visualizzata alla sinistra dell'URL nella barra degli indirizzi di un browser, quando si naviga sul sito. <br />Allegare un file di tipo .ico di almeno 48x48 pixel</p>
            <div class="row mb-3">
                <label for="Favicon" class="col-sm-3 col-form-label">
                    {def $_favicon_attribute = cond(
                        and( $homepage|has_attribute('favicon'), $homepage|attribute('favicon').has_content ),
                            $homepage|attribute('favicon'),
                            false()
                    )}
                    {def $_favicon = openpaini('GeneralSettings','favicon', 'favicon.ico')}
                    {def $_favicon_src = openpaini('GeneralSettings','favicon_src', 'ezimage')}
                    {if $_favicon_attribute}
                        <img alt="{ezini('SiteSettings','SiteName')}"
                             width="16"
                             height="16"
                             class="bg-primary"
                             src="{concat("content/download/",$_favicon_attribute.contentobject_id,"/",$_favicon_attribute.id,"/file/favicon.ico")|ezurl(no)}?v={$_favicon_attribute.version}" />
                    {elseif $_favicon_src|eq('ezimage')}
                        <img alt="{ezini('SiteSettings','SiteName')}"
                             width="16"
                             height="16"
                             class="bg-primary"
                             src="{$_favicon|ezimage(no)}" />
                    {else}
                        <img alt="{ezini('SiteSettings','SiteName')}"
                             width="16"
                             height="16"
                             class="bg-primary"
                             src="{$_favicon}" />
                    {/if}
                </label>
                <div class="col-sm-9">
                    <input type="file" name="Favicon" class="form-control" id="Favicon" value="">
                </div>
            </div>
        </div>

        {if is_set($homepage.data_map.apple_touch_icon)}
        <div class="border border-light rounded p-3 mb-3">
            <h5>Apple Touch Icon</h5>
            <p class="form-text">Icona per la schermata iniziale sui dispositivi mobili Apple e per i risultati nei motori di ricerca.<br />Allegare un file di tipo .png di 180x180 pixel</p>
            <div class="row mb-3">
                <label for="AppleTouchIcon" class="col-sm-3 col-form-label">
                    <img alt="{ezini('SiteSettings','SiteName')}"
                             width="50"
                             height="50"
                             src="{if $homepage.data_map.apple_touch_icon.has_content}{concat("content/download/",$homepage.data_map.apple_touch_icon.contentobject_id,"/",$homepage.data_map.apple_touch_icon.id,"/file/apple-touch-icon.png")|ezurl(no)}?v={$homepage.data_map.apple_touch_icon.version}{else}/extension/openpa_bootstrapitalia/design/standard/images/svg/icon.png{/if}" />
                </label>
                <div class="col-sm-9">
                    <input type="file" name="AppleTouchIcon" class="form-control" id="AppleTouchIcon" value="">
                </div>
            </div>
        </div>
        {/if}

        {if is_set($homepage.data_map.footer_logo)}
            <div class="border border-light rounded p-3 mb-3">
                <h5>Logo footer</h5>
                <div class="row mb-3">
                    <label for="LogoFooter" class="col-sm-3 col-form-label">
                        {if $homepage.data_map.footer_logo.has_content}
                            <img alt="{ezini('SiteSettings','SiteName')}"
                                 width="82"
                                 class="bg-primary"
                                 src="{$pagedata.homepage|attribute('footer_logo').content['header_logo'].full_path|ezroot(no)}" />
                        {/if}
                    </label>
                    <div class="col-sm-9">
                        <input type="file" name="LogoFooter" class="form-control" id="LogoFooter" value="">
                    </div>
                </div>
            </div>
        {/if}

        <div class="border border-light rounded p-3 mb-3">
            <h5>Link header</h5>
            <div class="row mb-3 ezcca-edit-datatype-ezobjectrelationlist">
                {include name=info_relation uri='design:bootstrapitalia/info/edit_relation.tpl' attribute=$homepage.data_map.link_nell_header attribute_base=ContentObjectAttribute max_items=5}
            </div>
        </div>

        <div class="border border-light rounded p-3 mb-3">
            <h5>Link footer</h5>
            <div class="row mb-3 ezcca-edit-datatype-ezobjectrelationlist">
                {include name=info_relation uri='design:bootstrapitalia/info/edit_relation.tpl' attribute=$homepage.data_map.link_nel_footer attribute_base=ContentObjectAttribute max_items=15}
            </div>
        </div>

        {if and( openpaini('GeneralSettings', 'ShowFooterBanner', 'disabled')|eq('enabled'), is_set($homepage.data_map.footer_banner) )}
            <div class="border border-light rounded p-3 mb-3">
                <h5>Banner footer</h5>
                <p class="text-muted">Viene visualizzato nel footer sulla destra il primo banner selezionato in questa sezione</p>
                <div class="row mb-3 ezcca-edit-datatype-ezobjectrelationlist">
                    {include name=info_relation uri='design:bootstrapitalia/info/edit_relation.tpl' attribute=$homepage.data_map.footer_banner attribute_base=ContentObjectAttribute max_items=1}
                </div>
            </div>
        {/if}

        <div class="row">
            <div class="col-12 text-right mt-3">
                <input type="submit" class="btn btn-success" name="Store" value="Salva"/>
            </div>
        </div>

    </form>
    {/if}

    {if $has_access_to_hot_zone}
        {include uri="design:bootstrapitalia/info_hot_zone.tpl"}
    {/if}

    {ezscript_require(array('jquery.relationsbrowse.js'))}
    <script>
        let relationI18n = {ldelim}
          clickToClose: "{'Click to close'|i18n('opendata_forms')}",
          clickToOpenSearch: "{'Click to open search engine'|i18n('opendata_forms')}",
          search: "{'Search'|i18n('opendata_forms')}",
          clickToBrowse: "{'Click to browse contents'|i18n('opendata_forms')}",
          browse: "{'Browse'|i18n('opendata_forms')}",
          createNew: "{'Create new'|i18n('opendata_forms')}",
          create: "{'Create'|i18n('opendata_forms')}",
          allContents: "{'All contents'|i18n('opendata_forms')}",
          clickToBrowseParent: "{'Click to view parent'|i18n('opendata_forms')}",
          noContents: "{'No contents'|i18n('opendata_forms')}",
          back: "{'Back'|i18n('opendata_forms')}",
          goToPreviousPage: "{'Go to previous'|i18n('opendata_forms')}",
          goToNextPage: "{'Go to next'|i18n('opendata_forms')}",
          clickToBrowseChildren: "{'Click to view children'|i18n('opendata_forms')}",
          clickToPreview: "{'Click to preview'|i18n('opendata_forms')}",
          preview: "{'Preview'|i18n('opendata_forms')}",
          closePreview: "{'Close preview'|i18n('opendata_forms')}",
          addItem: "{'Add'|i18n('opendata_forms')}",
          selectedItems: "{'Selected items'|i18n('opendata_forms')}",
          removeFromSelection: "{'Remove from selection'|i18n('opendata_forms')}",
          addToSelection: "{'Add to selection'|i18n('opendata_forms')}",
          store: "{'Store'|i18n('opendata_forms')}",
          storeLoading: "{'Loading...'|i18n('opendata_forms')}"
        {rdelim};
        {literal}
        $(document).ready(function () {
          $('.relations-searchbox').each(function () {
            let container = $(this)
            let getSelection = function (){
              let selection = [];
              container.find('input[type="checkbox"]').each(function () {
                let selected = parseInt($(this).val()) || 0;
                if (selected > 0) {
                  selection.push({contentobject_id: selected})
                }
              })
              return selection
            };
            let browserToggler = container.find('.relation_browser_toggler')
            let browser = container.find('.relation_browser')
            let maxItems = browser.data('relation_maxitems')
            let classes = browser.data('relation_classes')
            if (getSelection().length >= maxItems){
              browserToggler.hide()
            }
            let remover = container.find('.ezobject-relation-remove-button');

            browser.relationsbrowse({
              'attributeId': browser.data('relation_attribute'),
              'subtree': browser.data('relation_subtree'),
              'addCloseButton': true,
              'allowAllBrowse': true,
              'addCreateButton': false,
              'openInSearchMode': true,
              'classes': classes.length > 0 ? classes.split(',') : false,
              'i18n': relationI18n
            }).on('relationsbrowse.close', function (event, opendataBrowse) {
              browser.toggle();
            }).hide();

            browserToggler.on('click', function (e) {
              e.preventDefault();
              browser.data('plugin_relationsbrowse').setSelection(getSelection());
              browser.toggle();
            });

            browser.on('relationbrowse.change', function (e, relationBrowser) {
              if (relationBrowser.selection.length > 0){
                remover.show()
                if (relationBrowser.selection.length >= maxItems){
                  browserToggler.hide()
                  browser.hide()
                }
              } else {
                remover.hide()
              }
            })

            remover.on('click', function (e) {
              e.preventDefault();
              let isDone = false
              container.find('input[type="checkbox"]:checked').each(function () {
                $(this).parents('tr').remove();
                isDone = true
              });
              if (isDone) {
                browserToggler.show()
                if (getSelection().length > 0) {
                  remover.show()
                } else {
                  remover.hide()
                }
                browser.data('plugin_relationsbrowse').setSelection(getSelection());
              }
            })
          })
        })
        {/literal}
    </script>
    <style>
        .relations-searchbox .fa-stack.text-info{ldelim}
            display:none !important;
        {rdelim}
    </style>