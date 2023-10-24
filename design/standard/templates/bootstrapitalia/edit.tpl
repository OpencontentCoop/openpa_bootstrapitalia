{ezpagedata_set('show_path', false())}
{ezpagedata_set('has_container', true())}

<div class="p-3">
<div class="row row-column-menu-left">
    <div class="col-12 col-lg-3 my-4 border-col">
        <div class="cmp-navscroll sticky-top">
            <nav class="navbar it-navscroll-wrapper navbar-expand-lg">
                <div class="navbar-custom">
                    <div class="menu-wrapper">
{*                        <div class="link-list-wrapper mb-3 bg-light pb-3">*}
{*                            <div class="link-list-heading border-top pt-4"><i aria-hidden="true" class="fa fa-plus"></i> {'Create new'|i18n('opendata_forms')}</div>*}
{*                            <ul class="link-list pt-1" id="create-buttons"></ul>*}
{*                        </div>*}
                        <div class="link-list-wrapper mb-3" id="dashboardList">
                            <ul class="link-list"></ul>
                        </div>
                    </div>
                </div>
            </nav>
        </div>
    </div>

    <div class="col-12 col-lg-9" id="dashboardContainer">
        <div class="row">
            <div class="col-12">
                <div class="ps-lg-3 my-3 d-flex justify-content-sm-between">
                    <h3 data-title></h3>
                    <ul class="list-inline px-3" id="create-buttons"></ul>
                </div>
            </div>
            <div class="col-12">
                <div class="px-lg-3">
                    <table class="table" id="data"></table>
                </div>
            </div>
        </div>
    </div>
</div>
</div>
<div id="data-modal" class="modal fade modal-fullscreen" data-backdrop="static" style="z-index:10000">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-body">
                <div class="clearfix">
                    <button type="button" class="close" data-dismiss="modal" data-bs-dismiss="modal" aria-hidden="true">&times;</button>
                </div>
                <div id="data-form" class="clearfix p-4"></div>
            </div>
        </div>
    </div>
</div>

{ezscript_require(array(
    'handlebars.min.js',
    'bootstrap-datetimepicker.min.js',
    'jquery.fileupload.js',
    'jquery.fileupload-ui.js',
    'jquery.fileupload-process.js',
    'jquery.caret.min.js',
    'jquery.tag-editor.js',
    'alpaca.js',
    'jquery.price_format.min.js',
    'jquery.opendatabrowse.js',
    'jstree.min.js',
    'fields/OpenStreetMap.js',
    'fields/RelationBrowse.js',
    'fields/LocationBrowse.js',
    'fields/Tags.js',
    'fields/Ezxml.js',
    'fields/Tree.js',
    ezini('JavascriptSettings', 'IncludeScriptList', 'ocopendata_connectors.ini'),
    'jquery.opendataform.js'
))}
{def $plugin_list = ezini('EditorSettings', 'Plugins', 'ezoe.ini',,true() )
    $ez_locale = ezini( 'RegionalSettings', 'Locale', 'site.ini')
    $language = '-'|concat( $ez_locale )
    $dependency_js_list = array( 'ezoe::i18n::'|concat( $language ) )}
{foreach $plugin_list as $plugin}
    {set $dependency_js_list = $dependency_js_list|append( concat( 'plugins/', $plugin|trim, '/editor_plugin.js' ))}
{/foreach}
<script id="tinymce_script_loader" type="text/javascript" src={"javascript/tiny_mce_jquery.js"|ezdesign} charset="utf-8"></script>
{ezscript( $dependency_js_list )}
{ezcss_require(array(
    'alpaca.min.css',
    'bootstrap-datetimepicker.min.css',
    'jquery.fileupload.css',
    'jquery.tag-editor.css',
    'alpaca-custom.css',
    'jstree.min.css'
))}

<script>
  {literal}
  $(document).ready(function () {
    let ContainerSelector = "#data";
    let FormSelector = "#data-form";
    let ModalSelector = "#data-modal";
    let baseUrl = (typeof (UriPrefix) !== 'undefined' && UriPrefix !== '/') ? UriPrefix + '/' : '/';
    let tools = $.opendataTools;
    let pageLimit = 20;
    let dataContainer = $(ContainerSelector);
    let dashboardList = $('#dashboardList').html('');
    let dashboards = [];
    let currentDashboard;
    let selectCurrentDashboard = function (dasboard, dasboardItemElement) {
      $('[data-title]').html('...');
      dataContainer.html('');
      currentDashboard = dasboard;
      dashboardList.find('a').removeClass('font-weight-bold');
      dasboardItemElement.addClass('font-weight-bold');
      let buttonList = $('#create-buttons').html('');
      $.each(currentDashboard.createButtons, function () {
        let link = $('<a class="text-nowrap btn btn-outline-primary btn-xs" href="#" data-class="' + this.class + '" data-parent="' + this.parent + '"><i aria-hidden="true" class="fa fa-plus"></i> ' + this.name + '</a>')
          .on('click', function (e) {
            $(FormSelector).opendataFormCreate({
                class: $(this).data('class'),
                parent: $(this).data('parent')
              }, {
                onBeforeCreate: function () {
                  $(ModalSelector).modal('show');
                },
                onSuccess: function () {
                  $(ModalSelector).modal('hide');
                  loadContents();
                }
              }
            );
            e.preventDefault();
          });
        buttonList.append($('<li class="list-inline-item"></li>').append(link));
      });
      buildTable(function (){
        $('[data-title]').text(currentDashboard.title)
      });
    };
    let getCurrentDashboard = function () {
      return currentDashboard;
    };
    let buildTable = function (cb, context) {
      if ($.fn.dataTable.isDataTable(ContainerSelector)) {
        dataContainer.DataTable().destroy();
      }
      dataContainer.DataTable({
        // responsive: true,
        language: {url: '{/literal}{concat('javascript/datatable/',$ez_locale,'.json')|ezdesign(no)|shared_asset()}{literal}'},
        columns: getCurrentDashboard().columns,
        ajax: {
          url: '{/literal}{'opendata/api/datatable/search'|ezurl(no)}{literal}?q=' + getCurrentDashboard().mainQuery,
          type: 'GET'
        },
        processing: true,
        serverSide: true
      });
      if ($.isFunction(cb)) {
        cb.call(context);
      }
    }
    let loadContents = function (cb, context) {
      if (!currentDashboard) {
        selectCurrentDashboard();
      }
      buildTable(cb, context);
    };
    $.get('?dashboards', function (response){
      if (response.length > 0) {
        dashboards = response;
        $.each(dashboards, function (){
          let items = this.items;
          let bt = currentDashboard ? 'pt-4 border-top' : '';
          dashboardList.append('<div class="link-list-heading '+bt+'">'+this.name+'</div>');
          let dashboardItems = $('<ul class="link-list pt-1 pb-4"></ul>').appendTo(dashboardList);
          $.each(items, function () {
            let link = $('<a href="#">' + this.title + '</a>')
              .data('dashboard', this)
              .on('click', function (e) {
                selectCurrentDashboard($(this).data('dashboard'), $(this));
                e.preventDefault();
              });
            if (typeof currentDashboard !== 'object') {
              selectCurrentDashboard(this, link);
            }
            dashboardItems.append($('<li class="nav-item"></li>').append(link));
          });
        })
      }
    })
  });
  {/literal}
</script>

