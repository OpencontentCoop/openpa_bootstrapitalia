{def $zone_id = ''
     $block_id = ''
     $item_id = ''
     $zone_names = array()
     $zone_layout = cond( $attribute.content.zone_layout, $attribute.content.zone_layout, '' )
     $allowed_zones = fetch('ezflow', 'allowed_zones')
     $can_change_layout = fetch( 'user', 'has_access_to', hash( 'module', 'ezflow', 'function', 'changelayout' ) )
     $current_user = fetch( 'user', 'current_user' )
     $content_object = fetch( 'content', 'object', hash( 'object_id', $attribute.contentobject_id ) )
     $policies = fetch( 'user', 'user_role', hash( 'user_id', $current_user.contentobject_id ) )
     $layout_for_current_class = false()}

     {foreach $policies as $policy}
        {if and( eq( $policy.moduleName, 'ezflow' ),
                    eq( $policy.functionName, 'changelayout' ),
                        is_array( $policy.limitation ) )}
            {if $policy.limitation[0].values_as_array|contains( $content_object.content_class.id )}
                {set $layout_for_current_class = true()}
            {/if}
        {elseif or( and( eq( $policy.moduleName, '*' ),
                             eq( $policy.functionName, '*' ),
                                 eq( $policy.limitation, '*' ) ),
                    and( eq( $policy.moduleName, 'ezflow' ),
                             eq( $policy.functionName, '*' ),
                                 eq( $policy.limitation, '*' ) ),
                    and( eq( $policy.moduleName, 'ezflow' ),
                             eq( $policy.functionName, 'changelayout' ),
                                 eq( $policy.limitation, '*' ) ) )}
            {set $layout_for_current_class = true()}
        {/if}
     {/foreach}

    {if $zone_layout|ne( '' )}
        {set $zone_names = ezini( $zone_layout, 'ZoneName', 'zone.ini' )}
    {/if}

<div id="page-datatype-container" class="yui-skin-sam yui-skin-ezflow">
    {if and( $can_change_layout, $layout_for_current_class )}
    <div class="zones float-break">
    {foreach $allowed_zones as $allowed_zone}
        {if $allowed_zone['classes']|contains( $attribute.object.content_class.identifier )}
            <div class="zone">
                <div class="zone-label">{$allowed_zone['name']|wash()}</div>
                <div class="zone-thumbnail"><img src={concat( "ezpage/thumbnails/", $allowed_zone['thumbnail'] )|ezimage()} alt="{$allowed_zone['name']|wash()}" /></div>
                <div class="zone-selector">
                    <input type="radio" class="zone-type-selector" name="ContentObjectAttribute_ezpage_zone_allowed_type_{$attribute.id}" value="{$allowed_zone['type']}" {if eq( $allowed_zone['type'], $zone_layout )}checked="checked"{/if} />
                </div>
            </div>
        {/if}
    {/foreach}
        <div class="break"></div>

        <div id="zone-map-container" class="hide float-break">
            <div id="zone-map-type"></div>
            <p>{'The total number of zones in the new layout is less than the number of zones in the previous layout. Therefore, you must map the previous zones to new zones. Unmapped zones will be removed!'|i18n( 'design/standard/datatype/ezpage' )}</p>
            <div id="zone-map-placeholder"></div>
        </div>

        <div class="block">
            <input id="set-zone-layout" class="button" type="submit" name="CustomActionButton[{$attribute.id}_new_zone_layout]" value="{'Set layout'|i18n( 'design/standard/datatype/ezpage' )}" />
        </div>
        <input type="hidden" class="current-zone-count" name="ContentObjectAttribute_ezpage_zone_count_{$attribute.id}" value="{$attribute.content.zones|count()}" />
    </div>
    {/if}
    <div id="zone-tabs-container" data-attribute="{$attribute.id}-{$attribute.version}"></div>
    <div id="zone-modal" class="modal fade">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header" style="display: block">
                    <button type="button" class="close" data-dismiss="modal" data-bs-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                </div>
                <div class="modal-body p-2 relations-searchbox">
                </div>
            </div>
        </div>
    </div>
</div>

{ezscript_require( array( 'ezjsc::yui2', 'ezjsc::yui3', 'ezjsc::yui3io' ) )}

<script type="text/javascript">
(function() {ldelim}
    var loader = new YAHOO.util.YUILoader(YUI2_config);

    loader.onSuccess = function() {ldelim}
        YAHOO.ez.ZoneLayout.cfg = {ldelim} 'allowedzones': '{$allowed_zones|json()}',
                                           'zonelayout': '{$zone_layout}' {rdelim};
        YAHOO.ez.ZoneLayout.init();

        var tabView = new YAHOO.widget.TabView();

        {foreach $attribute.content.zones as $index => $zone}
            {if and( is_set( $zone.action ), eq( $zone.action, 'remove' ) )}{skip}{/if}
            tabView.addTab( new YAHOO.widget.Tab({ldelim}
                label: '{$zone_names[$zone.zone_identifier]}',
                dataSrc: '{concat( '/ezflow/zone/', $attribute.id, '/', $attribute.version, '/', $index  )|ezurl(no)}',
                cacheData: true
                {rdelim})
            );
        {/foreach}

        var i18nBrowser = {ldelim}
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
        {rdelim}

        {literal}

        var activeTabIndex = YAHOO.util.Cookie.get('eZPageActiveTabIndex');

        if (activeTabIndex) {
            if (tabView.getTab(activeTabIndex)) {
                tabView.set('activeIndex', activeTabIndex);
            } else {
                tabView.set('activeIndex', 0);
            }
        } else {
            tabView.set('activeIndex', 0);
        }

        var tabs = tabView.get("tabs");
        for (var i = 0; i < tabs.length; i++) {

            let tab = tabs[i]
            let tabIndex = i
            tab.loadHandler.success = function (o) {
              tab.set('content', o.responseText);
              YAHOO.ez.BlockCollapse.init();
              YAHOO.ez.sheduleDialog.init();

              $('#zone-tabs-container [name^=CustomActionButton]').on('click', function (e) {
                e.preventDefault()
                var modal = $('#zone-modal')
                var browser = modal.find('.relations-searchbox')
                var browserParameters = {
                  'addCloseButton': false,
                  'openInSearchMode': false,
                  'selectionType': 'single',
                  'browsePaginationLimit': 5,
                  'browseSort': 'name',
                  'browseOrder': '1',
                  'i18n': i18nBrowser
                }
                var destroyBrowser = function (){
                  browser
                    .html('')
                    .removeData('plugin_opendataBrowse')
                    .off('opendata.browse.select')
                    .off('opendata.browse.close')
                }
                $(document)
                  .on('hidden.bs.modal', '.modal', function () { destroyBrowser() })

                var pushAction = function (attrId, action, data){
                  console.log(attrId, action, data)
                  $('#zone-' + tabIndex + '-blocks').css('opacity', 0.4)
                  $.ez('ezjscpage::action::'+attrId+'::'+action, data, function (data) {
                    tab._dataConnect()
                  });
                }
                var attrId = $(this).parents('#zone-tabs-container').data('attribute')
                var action = $(this).attr('name')
                var data = $('form.edit').serializeArray()
                var confirmQuestion = $(this).data('confirm')
                if (confirmQuestion && !confirm(confirmQuestion)){
                  return
                }
                if (action.includes("_browse-")) {
                  browserParameters.subtree = $(this).data('browsersubtree') ? $(this).data('browsersubtree') : 1
                  browserParameters.selectionType = $(this).data('browserselectiontype') ? $(this).data('browserselectiontype') : 'single'
                  browser
                    .opendataBrowse(browserParameters)
                    .on('opendata.browse.select', function (event, opendataBrowse) {
                      destroyBrowser()
                      modal.modal('hide');
                      var newAction = action.replace('_browse', '')
                      var selectData = data
                      $.each(opendataBrowse.selection, function (){
                        selectData.push({name: 'SelectedNodeIDArray[]', value: this.node_id})
                      })
                      pushAction(attrId, newAction, selectData)
                    })
                    .on('opendata.browse.close', function (event, opendataBrowse) {
                      destroyBrowser()
                      modal.modal('hide');
                    })
                  modal.modal('show');
                } else {
                  pushAction(attrId, action, data)
                }
              })
            }

            tabs[i].on("dataLoadedChange", function (e) {
              YAHOO.util.Event.onContentReady("zone-tabs-container", function () {
                var cfg = {
                  url: "{/literal}{'ezflow/request'|ezurl('no')}{literal}",
                  attributeid: {/literal}{$attribute.id}{literal},
                  version: {/literal}{$attribute.version}{literal},
                  zone: tabView.getTabIndex(this)
                };
                YAHOO.ez.BlockDD.cfg = cfg;
                YAHOO.ez.BlockDD.init();
                YAHOO.ez.BlockCollapse.init();
                YAHOO.ez.sheduleDialog.init();
                BlockDDInit.cfg = cfg;
                BlockDDInit();
              }, this, true);
            });
        }

        tabView.on("activeTabChange", function(e) {
            var tabIndex = tabView.getTabIndex( e.newValue );
            YAHOO.util.Cookie.set("eZPageActiveTabIndex", tabIndex, {path: "/"});
            BlockDDInit.cfg.zone = tabIndex;
        });
        tabView.appendTo('zone-tabs-container');
        {/literal}
    {rdelim}

    loader.addModule({ldelim}
        name: 'blocktools',
        type: 'js',
        fullpath: '{"javascript/blocktools.js"|ezdesign( 'no' )}'
    {rdelim});

    loader.addModule({ldelim}
        name: 'zonetools',
        type: 'js',
        fullpath: '{"javascript/zonetools.js"|ezdesign( 'no' )}'
    {rdelim});

    loader.addModule({ldelim}
        name: 'scheduledialog',
        type: 'js',
        fullpath: '{"javascript/scheduledialog.js"|ezdesign( 'no' )}'
    {rdelim});

    loader.addModule({ldelim}
        name: 'scheduledialog-css',
        type: 'css',
        fullpath: '{"stylesheets/scheduledialog.css"|ezdesign( 'no' )}'
    {rdelim});

    loader.addModule({ldelim}
        name: 'pagedatatype-css',
        type: 'css',
        fullpath: '{"stylesheets/ezpage/ezpage.css"|ezdesign( 'no' )}'
    {rdelim});

    loader.require(["button","calendar","container","cookie","get","json","tabview","utilities","blocktools","zonetools","scheduledialog","scheduledialog-css", "pagedatatype-css"]);

    loader.insert();
{rdelim})();

function confirmDiscard( question )
{ldelim}
    // Ask user if he really wants to do it.
    return confirm( question );
{rdelim}
</script>
{if count($attribute.content.zones)|eq(1)}
<style>
    .yui-skin-ezflow ul.yui-nav{ldelim}display:none{rdelim}
    .yui-skin-ezflow .yui-content{ldelim}border:none !important;padding:0 !important;background:#fff !important;{rdelim}
</style>
{/if}
