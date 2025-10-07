<div class="row">
    <div class="col-12 mb-4">
        <h3>Configurazione calendari</h3>
    </div>
    <div class="col-12">
      <form id="filter-form">
        <div class="input-group">
          <select id="filter" style="max-width: 250px;border-top-left-radius: 4px;border-bottom-left-radius: 4px;border-right: none !important;" class="form-select border" aria-label="Filtra la ricerca per tipologia">
            <option value="1" selected>Cerca per ufficio</option>
            <option value="2">Cerca per servizio</option>
            <option value="3">Cerca per sede</option>
          </select>
          <label class="visually-hidden" for="query">Cerca</label>
          <input id="query" style="height: 48px;" placeholder="cerca nel titolo" type="text" class="form-control border" >
          <button id="reset" class="btn btn-danger d-none" type="reset">Annulla</button>
          <button id="find" class="btn btn-secondary" type="submit">Cerca</button>
          <button id="refresh" class="btn btn-warning ms-4 ml-4" type="submit">Rigenera cache API</button>
        </div>
      </form>
    </div>
    <div class="col-12">
        <div class="row mt-0 mb-5">
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

{ezscript_require(array('jsrender.js'))}

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
       <span class="badge bg-info">{{:metadata.id}}</span> {{:~i18n(metadata.name)}}
       <small class="d-block mt-2">{{for ~i18n(data, 'type')}}{{:#data}} {{/for}}</small>
       {{for ~i18n(data, 'has_spatial_coverage')}}
            <small data-place="{{:#data.id}}"></small>
       {{/for}}
    </a>
</li>
{{else}}
<li><em>Nessun risultato</em></li>
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
       <span class="badge bg-info">{{:metadata.id}}</span> {{:~i18n(metadata.name)}}
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
<li class="ps-0 pt-4 pb-4 text-uppercase"><span>Calendari per sedi</span></li>
{{for searchHits}}
<li class="row mb-5">
    <div class="col-12">
      <b><span class="badge bg-info">{{:metadata.id}}</span> {{:~i18n(metadata.name)}}</b> <i data-id="{{:metadata.id}}" class="fa fa-circle-o-notch fa-spin fa-fw" style="display:none"></i>
    </div>
    <div class="col-12" data-id="{{:metadata.id}}">
      {{include tmpl="#tpl-calendar-select"/}}
    </div>
    <div class="col-12">
      <div class="form-check form-check-group pb-0 my-0 border-0" style="box-shadow:none">
          <div class="toggles">
              <label for="EnableFilters-{{:metadata.id}}" class="mb-0 font-weight-normal">
                  Abilita il filtro sui calendari nel widget
                  <input type="checkbox" name="EnableFilters" id="EnableFilters-{{:metadata.id}}" value="1" {{if enable_filter}}checked = "checked"{{/if}}>
                  <span class="lever"></span>
              </label>
          </div>
      </div>
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

      let baseUrl = '/'
      if (typeof (UriPrefix) !== 'undefined' && UriPrefix !== '/') {
        baseUrl = UriPrefix + '/'
      }
      let tools = $.opendataTools
      $.views.helpers(tools.helpers)
      let pageLimit = 10
      let sectionSpinner = $($.templates('#tpl-spinner').render({}))
      let resetButton = $('#reset').on('click', function (e){
        reset()
        e.preventDefault()
      })
      let filterSelect = $('#filter')
      let queryInput = $('#query').val('')
      let findButton = $('#find').on('click', function (e){
        find()
        e.preventDefault()
      })

      let getQueryStringFilter = function (key){
        let nameFilter = ''
        let queryString = queryInput.val()
                .toString()
                .replace(/"/g, '\\\"')
                .replace(/'/g, "\\'")
                .replace(/\(/g, "\\(")
                .replace(/\)/g, "\\)")
        if (queryString.length > 0){
          nameFilter = key + " = '" + queryString + "' and "
        }

        return nameFilter
      }

      let loadTimeTable = function (calendars, placeId) {
        let container = $('[data-timetable="'+placeId+'"]')
        container.html(sectionSpinner.clone())
        $.getJSON(baseUrl + 'openpa/data/booking_config/timetable', {calendars: calendars}, function (response){
          let renderData = $($.templates('#tpl-timetable').render({rows: response}))
          container.html(renderData)
        })
      }

      let placeConfig = {
        originalQuery: "classes [place] sort [name=>asc]",
        query: null,
        getQuery: function (){
          return this.query ?? this.originalQuery
        },
        setQuery: function (query){
          this.query = query
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
          let selectCalendar = this.container.find('select')
          let update = function (select, toggle) {
            let calendars = select.val()
            let placeId = select.parent().data('id')
            let postData = {
              office: $('#office-list .nav-link.active').data('id'),
              service: $('#service-list .nav-link.active').data('id'),
              place: placeId,
              calendars: calendars,
              enable_filters: toggle.is(':checked') ? 1 : 0
            }
            let spinner = select.parents('.row').find('.fa-spin[data-id="'+postData.place+'"]').show()
            var csrfToken
            var tokenNode = document.getElementById('ezxform_token_js')
            if (tokenNode) {
              csrfToken = tokenNode.getAttribute('title')
            }
            $.ajax({
              url: baseUrl + 'openpa/data/booking_config',
              type: 'post',
              data: postData,
              headers: {"X-CSRF-TOKEN": csrfToken},
              dataType: 'json',
              success: function (response) {
                loadTimeTable(calendars, placeId)
                spinner.hide()
              },
              error: function () {
                spinner.hide()
              }
            })
          }
          selectCalendar.chosen().on('change', function(){
            update($(this), $(this).parents('li').find('[name="EnableFilters"]'))
          })
          selectCalendar.each(function (){
            let calendars = $(this).val()
            loadTimeTable(calendars, $(this).parent().data('id'))
          })

          this.container.find('[name="EnableFilters"]').on('change', function (e) {
            update($(this).parents('li').find('select'), $(this))
          })
        },
        decorate: function (item) {
          $.ajaxSetup({async: false})
          $.getJSON(baseUrl + 'openpa/data/booking_config/calendars', {
            office: $('#office-list .nav-link.active').data('id'),
            service: $('#service-list .nav-link.active').data('id'),
            place: item.metadata.id
          }, function (response) {
            item.calendars = []
            $.each(Calendars, function () {
              let i = $.extend({}, this)
              if ($.inArray(i.id, response.calendars) > -1) {
                i.selected = true
              }
              item.calendars.push(i)
            })
            item.enable_filter = response.enable_filter
          })
          $.ajaxSetup({async: true})
        },
        reset: function (){
          this.pagination.currentPage = 0
          this.pagination.queryPerPage = []
          this.container.html('')
          this.setQuery(null)
        }
      }

      let serviceConfig = {
        originalQuery: "classes [public_service] sort [name=>asc]",
        query: null,
        getQuery: function (){
          return this.query ?? this.originalQuery
        },
        setQuery: function (query){
          this.query = query
        },
        pagination: {
          currentPage: 0,
          queryPerPage: []
        },
        template: $.templates('#tpl-service-list'),
        container: $('#service-list'),
        onSelect: function (e){
          placeConfig.container.html(sectionSpinner)
          let places = []
          $('#office-list .nav-link.active').find('[data-place]').each(function (){
            places.push($(this).data('place'))
          })
          placeConfig.setQuery("classes [place] and id in ["+places.join(', ')+"] sort [name=>asc]")
          runQuery(placeConfig)
        },
        onRender: function (){},
        decorate: null,
        reset: function (){
          this.pagination.currentPage = 0
          this.pagination.queryPerPage = []
          this.container.html('')
          this.setQuery(null)
        }
      }

      let officeConfig = {
        originalQuery: "classes [organization] and raw[ezf_df_tags] in ['Ufficio'] sort [name=>asc]",
        query: null,
        getQuery: function (){
          let filters = ['']
          if (queryInput.val().length > 0) {
            let type = parseInt(filterSelect.val())
            if (type === 1) {
              filters.push(getQueryStringFilter('raw[attr_legal_name_t]'))
            } else if (type === 2) {
              $.ajaxSetup({async: false})
              $.ajax({
                type: "GET",
                url: tools.settings('endpoint').search,
                data: {q: getQueryStringFilter('raw[attr_name_t]') + ' facets [holds_role_in_time.id] ' + serviceConfig.getQuery()},
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data, textStatus, jqXHR) {
                  const facets = data?.facets[0]?.data || []
                  let keys = Object.keys(facets)
                  if (keys.length === 0) {
                    keys = [0]
                  }
                  filters.push('id in [' + keys.join(',') + ']')
                },
                error: function (jqXHR) {
                  console.log(jqXHR)
                  filters.push('id in [0]')
                }
              });
              $.ajaxSetup({async: true})
            } else if (type === 3) {
              filters.push(getQueryStringFilter('raw[submeta_has_spatial_coverage___name____t]'))
            }
          }
          let q = this.query ?? this.originalQuery
          return q + " " + filters.join(' and ')
        },
        setQuery: function (query){
          this.query = query
        },
        pagination: {
          currentPage: 0,
          queryPerPage: []
        },
        template: $.templates('#tpl-office-list'),
        container: $('#office-list'),
        onSelect: function (e){
          let selected = parseInt($(e.currentTarget).data('id'))
          placeConfig.container.html('')
          serviceConfig.container.html(sectionSpinner)
          serviceConfig.setQuery("classes [public_service] and holds_role_in_time.id = "+selected+" sort [name=>asc]")
          runQuery(serviceConfig)
        },
        onRender: function (){},
        decorate: null,
        reset: function (){
          this.pagination.currentPage = 0
          this.pagination.queryPerPage = []
          this.container.html('')
          this.setQuery(null)
        }
      }

      let runQuery = function (config, callback, context) {
        let currentQuery = config.getQuery()
        let query = config.getQuery()
        let currentPage = config.pagination.currentPage
        if (currentPage === 0){
          currentQuery += ' limit ' + pageLimit
        }
        tools.find(currentQuery, function (response) {
          response.currentPage = currentPage
          config.pagination.queryPerPage[currentPage] = query
          response.prevPageQuery = jQuery.type(config.pagination.queryPerPage[currentPage - 1]) === "undefined" ? null : config.pagination.queryPerPage[currentPage - 1]

          if ($.isFunction(config.decorate)) {
            $.each(response.searchHits, function () {
              config.decorate(this)
            })
          }

          let renderData = $(config.template.render(response))
          if ($.isFunction(callback)) {
            callback.call(context, renderData)
          }
          config.container.html(renderData)
          config.container.find('.nav-link').on('click', function (e) {
            config.onSelect(e)
            e.preventDefault()
          })
          config.container.find('.nextPage').on('click', function (e) {
            config.pagination.currentPage++
            config.setQuery($(this).data('query'))
            runQuery(config)
            e.preventDefault()
          })
          config.container.find('.prevPage').on('click', function (e) {
            config.pagination.currentPage--
            config.setQuery($(this).data('query'))
            runQuery(config)
            e.preventDefault()
          })
          config.onRender()
        })
      }

      let loadOffices = function () {
        officeConfig.container.html(sectionSpinner)
        runQuery(officeConfig)
      }

      let find = function (){
        if (queryInput.val().length > 0){
          resetButton.removeClass('d-none')
          officeConfig.reset()
          placeConfig.reset()
          serviceConfig.reset()
          loadOffices()
        }
      }

      let reset = function (){
        queryInput.val('')
        filterSelect.val(1)
        resetButton.addClass('d-none')
        officeConfig.reset()
        placeConfig.reset()
        serviceConfig.reset()
        loadOffices()
      }
      reset()
    })

    $('#refresh').on('click', function (e){
      $.get('/api/openapi/booking-config?refresh=true')
      e.preventDefault()
    })
    {/literal}
</script>