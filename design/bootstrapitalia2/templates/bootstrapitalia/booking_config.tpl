<div class="row">
    <div class="col-12">
        <h3>Configurazione calendari</h3>
    </div>
    <div class="col-12">
        <div class="row mt-4 mb-5">
            <div class="col-3">
                <ul id="office-list" class="nav nav-tabs nav-tabs-vertical" role="tablist" style="height: 100%"
                    aria-orientation="vertical"></ul>
            </div>
            <div class="col-3">
                <ul id="service-list" class="nav nav-tabs nav-tabs-vertical" role="tablist" style="height: 100%"
                    aria-orientation="vertical"></ul>
            </div>
          <div class="col-6">
            <ul id="place-list" style="height: 100%"
                aria-orientation="vertical"></ul>
          </div>
        </div>
    </div>
</div>

{ezscript_require(array('jsrender.js','jquery.opendataform.js'))}

{literal}
<script id="tpl-calendar-select" type="text/x-jsrender">
<select class="form-control" multiple data-placeholder="Seleziona...">
  <option></option>
  {{for calendars}}
    <option value="{{:id}}"{{if selected}} selected{{/if}}>{{:title}}</option>
  {{/for}}
</select>
</script>
{/literal}

{literal}
<script id="tpl-timetable" type="text/x-jsrender">
<table class="table table-sm table-bordered mt-3" style="font-size: .75em;">
  {{for rows}}
    <tr>
    {{if #getIndex() == 0}}
      {{for #data}}
        <th>{{:#data}}</th>
      {{/for}}
    {{else}}
      {{for #data}}
        <td><p style="margin:0;width:80px;white-space: nowrap;overflow: hidden;text-overflow: ellipsis;" title="{{:#data}}">{{for #data}}{{:#data}}<br />{{/for}}</p></td>
      {{/for}}
    {{/if}}
    </tr>
  {{/for}}
</table>
</script>
{/literal}

{literal}
<script id="tpl-office-list" type="text/x-jsrender">
<li class="ps-0 pt-4 pb-2 text-uppercase"><span>Uffici</span></li>
{{for searchHits}}
<li class="nav-item">
    <a class="nav-link ps-0 d-block mw-100" data-bs-toggle="tab" data-id="{{:metadata.id}}" href="#">
       {{:~i18n(metadata.name)}}
       <small class="d-block mt-2">{{for ~i18n(data, 'type')}}{{:#data}} {{/for}}</small>
       {{for ~i18n(data, 'has_spatial_coverage')}}
            <small data-place="{{:#data.id}}"></small>
       {{/for}}
    </a>
</li>
{{/for}}
{{if prevPageQuery || nextPageQuery }}
    <li class="nav-item d-flex justify-content-between mx-2">
        {{if prevPageQuery}}
            <a href="#" class="prevPage" data-query="{{>prevPageQuery}}"><i class="fa fa-arrow-left"></i></a>
        {{else}}
            <a href="#"></a>
        {{/if}}
        {{if nextPageQuery }}
            <a href="#" class="nextPage" data-query="{{>nextPageQuery}}"><i class="fa fa-arrow-right"></i></a>
        {{else}}
            <a href="#"></a>
        {{/if}}
    </li>
{{/if}}
</script>
{/literal}

{literal}
<script id="tpl-service-list" type="text/x-jsrender">
<li class="ps-0 pt-4 pb-2 text-uppercase"><span>Prenotazioni</span></li>
<li class="nav-item">
    <a class="nav-link ps-0 d-block mw-100" data-bs-toggle="tab" data-id="0" href="#">
       Appuntamento generico
    </a>
</li>
<li class="ps-0 pt-4 pb-2 text-uppercase"><span>Prenotazioni per servizi</span></li>
{{for searchHits}}
<li class="nav-item">
    <a class="nav-link ps-0 d-block mw-100" data-bs-toggle="tab" data-id="{{:metadata.id}}" href="#">
       {{:~i18n(metadata.name)}}
    </a>
</li>
{{else}}
<li class="ps-0"><em>Nessun servizio erogato</em></li>
{{/for}}
{{if prevPageQuery || nextPageQuery }}
    <li class="nav-item d-flex justify-content-between mx-2">
        {{if prevPageQuery}}
            <a href="#" class="prevPage" data-query="{{>prevPageQuery}}"><i class="fa fa-arrow-left"></i></a>
        {{else}}
            <a href="#"></a>
        {{/if}}
        {{if nextPageQuery }}
            <a href="#" class="nextPage" data-query="{{>nextPageQuery}}"><i class="fa fa-arrow-right"></i></a>
        {{else}}
            <a href="#"></a>
        {{/if}}
    </li>
{{/if}}
</script>
{/literal}

{literal}
<script id="tpl-place-list" type="text/x-jsrender">
<li class="ps-0 pt-4 pb-4 text-uppercase"><span>Calendari per sede</span></li>
{{for searchHits}}
<li class="row mb-5">
    <div class="col-12">
      <b>{{:~i18n(metadata.name)}}</b> <i data-id="{{:metadata.id}}" class="fa fa-circle-o-notch fa-spin fa-fw" style="display:none"></i>
    </div>
    <div class="col-12" data-id="{{:metadata.id}}">
      {{include tmpl="#tpl-calendar-select"/}}
    </div>
    <div class="col-12" data-timetable="{{:metadata.id}}"></div>
</li>
{{else}}
    <li class="ps-0"><em>Nessun luogo collegato</em></li>
{{/for}}
{{if prevPageQuery || nextPageQuery }}
    <li class="nav-item d-flex justify-content-between mx-2">
        {{if prevPageQuery}}
            <a href="#" class="prevPage" data-query="{{>prevPageQuery}}"><i class="fa fa-arrow-left"></i></a>
        {{else}}
            <a href="#"></a>
        {{/if}}
        {{if nextPageQuery }}
            <a href="#" class="nextPage" data-query="{{>nextPageQuery}}"><i class="fa fa-arrow-right"></i></a>
        {{else}}
            <a href="#"></a>
        {{/if}}
    </li>
{{/if}}
</script>
<script id="tpl-spinner" type="text/x-jsrender">
<div class="col-xs-12 spinner text-center mt-5">
    <i class="fa fa-circle-o-notch fa-spin fa-2x fa-fw"></i>
</div>
</script>
{/literal}
<style>
  .chosen-container-multi .chosen-choices .search-choice{ldelim}max-width: 580px !important{rdelim}
  .nav-tabs.nav-tabs-vertical .nav-link{ldelim}border-right-width: 5px;{rdelim}
</style>
<script type="text/javascript" language="javascript">
  var Calendars = [{foreach $calendars as $calendar}{ldelim}"id":"{$calendar.id|wash()}","title":"{$calendar.title|wash()}","selected":false{rdelim}{delimiter},{/delimiter}{/foreach}];
  {literal}
    $(document).ready(function () {

      let baseUrl = '/';
      if (typeof (UriPrefix) !== 'undefined' && UriPrefix !== '/') {
        baseUrl = UriPrefix + '/';
      }

      let tools = $.opendataTools;
      $.views.helpers(tools.helpers);

      let pageLimit = 15;
      let sectionSpinner = $($.templates('#tpl-spinner').render({}));

      let loadTimeTable = function (calendars, placeId)
      {
        let container = $('[data-timetable="'+placeId+'"]');
        container.html(sectionSpinner.clone());
        $.getJSON(baseUrl + 'openpa/data/booking_config/timetable', {calendars: calendars}, function (response){
          console.log(response);
          let renderData = $($.templates('#tpl-timetable').render({rows: response}));
          container.html(renderData);
        });
      }

      let placeConfig = {
        query: "classes [place] sort [name=>asc] limit " + pageLimit,
        getQuery: function (){
          return this.query;
        },
        setQuery: function (query){
          return this.query = query;
        },
        pagination: {
          currentPage: 0,
          queryPerPage: []
        },
        template: $.templates('#tpl-place-list'),
        container: $('#place-list'),
        onSelect: function (e){
        },
        onRender: function (){
          let selectCalendar = this.container.find('select');
          selectCalendar.chosen().on('change', function(){
            let calendars = $(this).val();
            let placeId = $(this).parent().data('id');
            let postData = {
              office: $('#office-list .nav-link.active').data('id'),
              service: $('#service-list .nav-link.active').data('id'),
              place: placeId,
              calendars: calendars
            };
            let spinner = $(this).parents('.row').find('.fa-spin[data-id="'+postData.place+'"]').show();
            var csrfToken;
            var tokenNode = document.getElementById('ezxform_token_js');
            if (tokenNode) {
              csrfToken = tokenNode.getAttribute('title');
            }
            $.ajax({
              url: baseUrl + 'openpa/data/booking_config',
              type: 'post',
              data: postData,
              headers: {"X-CSRF-TOKEN": csrfToken},
              dataType: 'json',
              success: function (response) {
                loadTimeTable(calendars, placeId)
                spinner.hide();
              },
              error: function () {
                spinner.hide();
              }
            });
          })
          selectCalendar.each(function (){
            let calendars = $(this).val();
            loadTimeTable(calendars, $(this).parent().data('id'));
          })
        },
        decorate: function (item) {
          $.ajaxSetup({async: false});
          $.getJSON(baseUrl + 'openpa/data/booking_config/calendars', {
            office: $('#office-list .nav-link.active').data('id'),
            service: $('#service-list .nav-link.active').data('id'),
            place: item.metadata.id
          }, function (response) {
            item.calendars = [];
            $.each(Calendars, function () {
              let i = $.extend({}, this);
              if ($.inArray(i.id, response) > -1) {
                i.selected = true;
              }
              item.calendars.push(i);
            })
          })
          $.ajaxSetup({async: true});
        }
      }

      let serviceConfig = {
        query: "classes [public_service] sort [name=>asc] limit " + pageLimit,
        getQuery: function (){
          return this.query;
        },
        setQuery: function (query){
          return this.query = query;
        },
        pagination: {
          currentPage: 0,
          queryPerPage: []
        },
        template: $.templates('#tpl-service-list'),
        container: $('#service-list'),
        onSelect: function (e){
          placeConfig.container.html(sectionSpinner);
          let places = [];
          $('#office-list .nav-link.active').find('[data-place]').each(function (){
            places.push($(this).data('place'))
          });
          placeConfig.setQuery("classes [place] and id in ["+places.join(', ')+"] sort [name=>asc] limit " + pageLimit)
          runQuery(placeConfig);
        },
        onRender: function (){},
        decorate: null
      }

      let officeConfig = {
        query: "classes [organization] and type in ['Ufficio', 'Area', '\"Struttura amministrativa\"'] sort [name=>asc] limit " + pageLimit,
        getQuery: function (){
          return this.query;
        },
        setQuery: function (query){
          return this.query = query;
        },
        pagination: {
          currentPage: 0,
          queryPerPage: []
        },
        template: $.templates('#tpl-office-list'),
        container: $('#office-list'),
        onSelect: function (e){
          let selected = parseInt($(e.currentTarget).data('id'));
          placeConfig.container.html('');
          serviceConfig.container.html(sectionSpinner);
          serviceConfig.setQuery("classes [public_service] and holds_role_in_time.id = "+selected+" sort [name=>asc] limit " + pageLimit)
          runQuery(serviceConfig);
        },
        onRender: function (){},
        decorate: null
      }

      let runQuery = function (config) {
        let query = config.getQuery();
        let currentPage = config.pagination.currentPage;
        tools.find(query, function (response) {
          response.currentPage = currentPage;
          config.pagination.queryPerPage[currentPage] = query;
          response.prevPageQuery = jQuery.type(config.pagination.queryPerPage[currentPage - 1]) === "undefined" ? null : config.pagination.queryPerPage[currentPage - 1];

          if ($.isFunction(config.decorate)) {
            $.each(response.searchHits, function () {
              config.decorate(this);
            });
          }

          let renderData = $(config.template.render(response));
          config.container.html(renderData);
          config.container.find('.nav-link').on('click', function (e) {
            config.onSelect(e);
            e.preventDefault();
          });
          config.container.find('.nextPage').on('click', function (e) {
            config.pagination.currentPage++;
            config.setQuery($(this).data('query'));
            runQuery(config);
            e.preventDefault();
          });
          config.container.find('.prevPage').on('click', function (e) {
            config.pagination.currentPage--;
            config.setQuery($(this).data('query'));
            runQuery(config);
            e.preventDefault();
          });
          config.onRender();
        });
      };
      let loadOffices = function () {
        runQuery(officeConfig);
      };
      loadOffices();
    });
    {/literal}
</script>