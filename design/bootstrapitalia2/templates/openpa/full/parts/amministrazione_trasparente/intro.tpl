<h1>{$node.name|wash()}</h1>
{attribute_view_gui attribute=$node|attribute('intro') image_class=reference alignment=center}

{if openpaini('Trasparenza', 'UseCustomTemplate', 'disabled')|eq('enabled')}
<form id="search-trasparenza" class="mb-3" action="{'content/search'|ezurl(no)}" method="get" data-subtree="{$node.node_id}">
    <div class="form-group floating-labels mb-0">
        <div class="form-label-group mb-0">
            <input type="text"
                   autocomplete="off"
                   class="form-control"
                   id="search-text"
                   name="SearchText"
                   placeholder="{'Search in'|i18n('bootstrapitalia')} {$node.name|wash()}"/>
            <label class="" for="search-text">
                {'Search in'|i18n('bootstrapitalia')} {$node.name|wash()}
            </label>
            <button type="submit" class="autocomplete-icon btn btn-link" aria-label="{'Search'|i18n('openpa/search')}">
                {display_icon('it-search', 'svg', 'icon')}
            </button>
        </div>
    </div>
    <ul id="search-trasparenza-results" class="list-group" style="display: none" data-noresults="{'No results were found'|i18n('openpa/search')}"></ul>
</form>
{literal}
<script>
    $('#search-trasparenza').on('submit', function (e){
      e.preventDefault();
      let searchText = $('#search-text').val();
      let resultList = $('#search-trasparenza-results');
      let quotedValue = searchText.toString()
        .replace(/"/g, '\\"')
        .replace(/'/g, "\\'")
        .replace(/\(/g, "\\(")
        .replace(/\)/g, "\\)")
        .replace(/\[/g, "\\[")
        .replace(/\]/g, "\\]");
      if (searchText.length > 0){
        let q = 'q = \'' + quotedValue + '\' and subtree ['+ $(this).data('subtree') +'] sort [score=>desc] limit 15';
        $.opendataTools.find(q, function (response){
          resultList.show().html('');
          if (response.totalCount === 0){
            resultList.append('<li class="list-group-item">' + resultList.data('noresults') + '</li>')
          }else {
            $.each(response.searchHits, function () {
              resultList.append(
                '<li class="list-group-item p-2">' +
                '<a class="d-inline" href="/openpa/object/'+this.metadata.id+'">' + $.opendataTools.helpers.i18n(this.metadata.name) + '</a>' +
                '<small class="ps-2 form-text text-muted text-nowrap">' + $.opendataTools.helpers.i18n(this.metadata.classDefinition.name) + '</small>' +
                '</li>'
              )
            })
          }
        })
      }else{
        resultList.hide().html('');
      }
    })
</script>
{/literal}
{/if}