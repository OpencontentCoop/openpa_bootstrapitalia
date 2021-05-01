{ezscript_require(array('jsrender.js'))}
{default attribute_base='ContentObjectAttribute' html_class='full' placeholder=false()}
{if and( $attribute.has_content, $placeholder )}<label>{$placeholder}</label>{/if}
    <input {if $placeholder}placeholder="{$placeholder}"{/if}
           id="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}"
           class="{$html_class} ezcc-{$attribute.object.content_class.identifier} ezcca-{$attribute.object.content_class.identifier}_{$attribute.contentclass_attribute_identifier}"
           type="text" size="70"
           name="{$attribute_base}_ezstring_data_text_{$attribute.id}"
           value="{$attribute.data_text|wash( xhtml )}" />
    <div data-fields_gui="ezcoa-{if ne( $attribute_base, 'ContentObjectAttribute' )}{$attribute_base}-{/if}{$attribute.contentclassattribute_id}_{$attribute.contentclass_attribute_identifier}">
    </div>
{/default}
{def $classes = fetch( 'class', 'list' )}
{literal}
<script id="tpl-fields-gui" type="text/x-jsrender">
<div data-fields_gui_item class="card no-after card-bg mb-3">
    <div class="card-body">
        <div class="row mb-1 border-bottom pb-1">
            <div class="col-sm-3 font-weight-bold">Ramo dell'alberatura</div>
            <div class="col-sm-8" data-parent={{>parent}}>{{:parentName}}</div>
            <div class="col-sm-1">
                <a href="#" data-modify="parent"><span class="fa-stack"><i aria-hidden="true" class="fa fa-square fa-stack-2x"></i><i aria-hidden="true" class="fa fa-pencil fa-stack-1x fa-inverse"></i></span></a>
                <a href="#" class="hide" data-cancel="parent"><span class="fa-stack"><i aria-hidden="true" class="fa fa-square fa-stack-2x text-danger"></i><i aria-hidden="true" class="fa fa-times fa-stack-1x fa-inverse"></i></span></a>
            </div>
        </div>
        <div class="row mb-1 border-bottom pb-1">
            <div class="col-sm-3 font-weight-bold">Tipologia di contenuti</div>
            <div class="col-sm-8" data-class={{>class}}>{{:contentClassName}}</div>
            <div class="col-sm-1">
                <a href="#" data-modify="class"><span class="fa-stack"><i aria-hidden="true" class="fa fa-square fa-stack-2x"></i><i aria-hidden="true" class="fa fa-pencil fa-stack-1x fa-inverse"></i></span></a>
                <a href="#" class="hide" data-cancel="class"><span class="fa-stack"><i aria-hidden="true" class="fa fa-square fa-stack-2x text-danger"></i><i aria-hidden="true" class="fa fa-times fa-stack-1x fa-inverse"></i></span></a>
            </div>
        </div>
        <div class="row mb-1 border-bottom pb-1">
            <div class="col-sm-3 font-weight-bold">Campi da visualizzare</div>
            <div class="col-sm-8" data-fields={{>fields}}>
            <ul class="list-unstyled mb-0">
            {{for fieldNameList}}
                <li>{{:fieldName}}</li>
            {{/for}}
            </ul>
            </div>
            <div class="col-sm-1">
            {{if class}}
                <a href="#" data-modify="fields"><span class="fa-stack"><i aria-hidden="true" class="fa fa-square fa-stack-2x"></i><i aria-hidden="true" class="fa fa-pencil fa-stack-1x fa-inverse"></i></span></a>
                <a href="#" class="hide" data-cancel="fields"><span class="fa-stack"><i aria-hidden="true" class="fa fa-square fa-stack-2x text-danger"></i><i aria-hidden="true" class="fa fa-times fa-stack-1x fa-inverse"></i></span></a>
            {{/if}}
            </div>
        </div>
        <div class="row mb-1 border-bottom pb-1">
            <div class="col-sm-3 font-weight-bold">Ordinamento</div>
            <div class="col-sm-8" data-order_by={{>order_by}}>
            <ul class="list-unstyled mb-0">
            {{for sortNameList}}
                <li><strong>{{:fieldName}}:</strong> {{:direction}}</li>
            {{/for}}
            </ul>
            </div>
            <div class="col-sm-1">
            {{if class}}
                <a href="#" data-modify="order_by"><span class="fa-stack"><i aria-hidden="true" class="fa fa-square fa-stack-2x"></i><i aria-hidden="true" class="fa fa-pencil fa-stack-1x fa-inverse"></i></span></a>
                <a href="#" class="hide" data-cancel="order_by"><span class="fa-stack"><i aria-hidden="true" class="fa fa-square fa-stack-2x text-danger"></i><i aria-hidden="true" class="fa fa-times fa-stack-1x fa-inverse"></i></span></a>
            {{/if}}
            </div>
        </div>
        <div class="row">
            <div class="col-sm-3 font-weight-bold">Filtri</div>
            <div class="col-sm-8" data-filters={{>filters}}>
            <ul class="list-unstyled mb-0">
            {{for filterNameList}}
                <li><strong>{{if fieldName}}{{:fieldName}}{{else}}<em>{{>field}}</em>{{/if}}:</strong> {{>value}}</li>
            {{/for}}
            </ul>
            </div>
            <div class="col-sm-1">
            {{if class}}
                <a href="#" data-modify="filters"><span class="fa-stack"><i aria-hidden="true" class="fa fa-square fa-stack-2x"></i><i aria-hidden="true" class="fa fa-pencil fa-stack-1x fa-inverse"></i></span></a>
                <a href="#" class="hide" data-cancel="filters"><span class="fa-stack"><i aria-hidden="true" class="fa fa-square fa-stack-2x text-danger"></i><i aria-hidden="true" class="fa fa-times fa-stack-1x fa-inverse"></i></span></a>
            {{/if}}
            </div>
        </div>
        <div class="row mb-1 border-bottom pb-1 hide">
            <div class="col-sm-3 font-weight-bold">Raggruppamento</div>
            <div class="col-sm-8" data-group_by={{>group_by}}>{{if group_by}}{{:group_by}}{{/if}}</div>
            <div class="col-sm-1">
                <a href="#" data-modify="group_by"><span class="fa-stack"><i aria-hidden="true" class="fa fa-square fa-stack-2x"></i><i aria-hidden="true" class="fa fa-pencil fa-stack-1x fa-inverse"></i></span></a>
                <a href="#" class="hide" data-cancel="group_by"><span class="fa-stack"><i aria-hidden="true" class="fa fa-square fa-stack-2x text-danger"></i><i aria-hidden="true" class="fa fa-times fa-stack-1x fa-inverse"></i></span></a>
            </div>
        </div>
        <div class="row hide">
            <div class="col-sm-3 font-weight-bold">Profondita nell'alberatura</div>
            <div class="col-sm-8" data-depth={{>depth}}>{{if depth}}{{:depth}}{{/if}}</div>
            <div class="col-sm-1">
                <a href="#" data-modify="depth"><span class="fa-stack"><i aria-hidden="true" class="fa fa-square fa-stack-2x"></i><i aria-hidden="true" class="fa fa-pencil fa-stack-1x fa-inverse"></i></span></a>
                <a href="#" class="hide" data-cancel="depth"><span class="fa-stack"><i aria-hidden="true" class="fa fa-square fa-stack-2x text-danger"></i><i aria-hidden="true" class="fa fa-times fa-stack-1x fa-inverse"></i></span></a>
            </div>
        </div>
    </div>
</div>
</script>
<script id="tpl-class-select" type="text/x-jsrender">
<select class="form-control">
    {/literal}
    {foreach $classes as $class}
        <option {ldelim}{ldelim}if current == '{$class.identifier}'{rdelim}{rdelim}selected="selected"{ldelim}{ldelim}/if{rdelim}{rdelim}
                value="{$class.identifier}">
            {$class.name}
        </option>
    {/foreach}
    {literal}
</select>
</script>
<script id="tpl-attribute-select" type="text/x-jsrender">
<select class="form-control attribute-select">
    {{for contentClass.fields ~current=current ~disabledFields=disabledFields}}
        <option {{if ~current == identifier}}selected="selected"{{/if}}
                {{if ~disabledFields}}{{for ~disabledFields ~identifier=identifier}}{{if #data == ~identifier}} disabled="disabled"{{/if}}{{/for}}{{/if}}
                value="{{:identifier}}">
           {{:~i18n(name)}}
        </option>
    {{/for}}
</select>
</script>
<script id="tpl-attribute-checkbox" type="text/x-jsrender">
<div>
    {{for contentClass.fields ~current=current}}
        <label class="checkbox d-block">
        <input type="checkbox" {{for ~current ~identifier=identifier}}{{if #data == ~identifier}}checked="checked"{{/if}}{{/for}}
                value="{{:identifier}}" />
           {{:~i18n(name)}}
        </label>
    {{/for}}
</div>
</script>
<script id="tpl-store-button" type="text/x-jsrender">
<a href="#" class="float-right mt-2 store-field btn btn-xs btn-secondary">Salva</a>
</script>
<script id="tpl-add-item-button" type="text/x-jsrender">
<a href="#" class="float-left mt-2 add-field-item btn btn-xs btn-secondary">Aggiungi</a>
</script>
<script id="tpl-add-custom-item-button" type="text/x-jsrender">
<a href="#" class="float-left mt-2 ml-2 add-custom-field-item btn btn-xs btn-secondary">Aggiungi <em>custom</em></a>
</script>
<script id="tpl-remove-item-button" type="text/x-jsrender">
<a href="#" class="remove-field-item"><i class="fa fa-times"></i></a>
</script>
<script id="tpl-sort-direction" type="text/x-jsrender">
<select class="form-control sort-direction">
    <option {{if direction == 'Ascendente'}}selected="selected"{{/if}}
            value="Ascendente">Ascendente</option>
    <option {{if direction == 'Discendente'}}selected="selected"{{/if}}
            value="Discendente">Discendente</option>
</select>
</script>
<script id="tpl-sort-item" type="text/x-jsrender">
<div class="row sort-item">
    <div class="col">{{include tmpl="#tpl-attribute-select"/}}</div>
    <div class="col">{{include tmpl="#tpl-sort-direction"/}}</div>
    <div class="col">{{include tmpl="#tpl-remove-item-button"/}}</div>
</div>
</script>
<script id="tpl-filter-item" type="text/x-jsrender">
<div class="row filter-item">
    <div class="col">{{include tmpl="#tpl-attribute-select"/}}</div>
    <div class="col"><input type="text" value="{{:operator}}" /></div>
    <div class="col"><input type="text" value="{{:value}}" /></div>
    <div class="col">{{include tmpl="#tpl-remove-item-button"/}}</div>
</div>
</script>
<script id="tpl-custom-filter-item" type="text/x-jsrender">
<div class="row filter-item">
    <div class="col"><input type="text" value="{{:current}}" /></div>
    <div class="col"><input type="text" value="{{:operator}}" /></div>
    <div class="col"><input type="text" value="{{:value}}" /></div>
    <div class="col">{{include tmpl="#tpl-remove-item-button"/}}</div>
</div>
</script>
<script>
    $(document).ready(function (){
        $.views.helpers($.opendataTools.helpers);
        var allContent = "{/literal}{'All content'|i18n('design/admin/content/search')}{literal}";
        var stringQueryFieldsParser = function (value) {
            var result = {
                'query': value,
                'parent': null,
                'depth': null,
                'class': null,
                'filters': null,
                'group_by': null,
                'order_by': null,
                'fields': [],
                'parentNode': null,
                'parentName': allContent,
                'contentClass': '',
                'contentClassName': null,
                'contentClassAttributes': {},
                'fieldNameList': [],
                'filterNameList': [],
                'sortNameList': [],
            };
            function findParent(parent){
                if (parent === 1 || !parent){
                    return null;
                }
                $.ajax({
                    cache: true,
                    url: '/opendata/api/content/search/raw[meta_node_id_si] = '+parent,
                    async: false,
                    type: 'get',
                    success: function (response) {
                        if (response && response.totalCount > 0) {
                            result.parentNode = response.searchHits[0];
                            result.parentName = response.searchHits[0].metadata.name[$.opendataTools.settings('language')];
                        }
                    }
                })
            }
            function findContentClass(identifier){
                if (!identifier) return;
                $.ajax({
                    cache: true,
                    url: '/opendata/api/classes/'+identifier,
                    async: false,
                    type: 'get',
                    success: function (response) {
                        if (response) {
                            result.contentClass = response;
                            result.contentClassName = result.contentClass.name[$.opendataTools.settings('language')]
                            $.each(result.contentClass.fields, function (){
                                result.contentClassAttributes[this.identifier] = this;
                            });
                        }
                    }
                })
            }
            function findFieldNameList(fields){
                if (result.contentClass){
                    $.each(fields, function (){
                        if (result.contentClassAttributes.hasOwnProperty(this)){
                            result.fieldNameList.push({
                                'fieldName': result.contentClassAttributes[this].name[$.opendataTools.settings('language')]
                            });
                        }
                    })
                }
            }
            function findFilterNameList(filters){
                if (!filters || filters.length === 0) return;
                if (result.contentClass){
                    $.ajax({
                        cache: true,
                        url: '/opendata/analyzer',
                        async: false,
                        type: 'get',
                        data: {query: filters},
                        success: function (response) {
                            if (response.analysis) {
                                $.each(response.analysis, function () {
                                    if (this.type === 'filter') {
                                        result.filterNameList.push({
                                            'fieldName': result.contentClassAttributes.hasOwnProperty(this.field) ?
                                                result.contentClassAttributes[this.field].name[$.opendataTools.settings('language')] : null,
                                            'field': this.field,
                                            'operator': this.operator,
                                            'value': this.value.replace(/"/g, "").replace(/'/g, "").replace(/\[/g, "").replace(/]/g, ""),
                                            'format': this.format,
                                        });
                                    }
                                });
                            }
                        }
                    })
                }
            }
            function findSortNameList(sorts){
                if (!sorts || sorts.length === 0) return;
                if (result.contentClass){
                    $.each(sorts, function (){
                        var direction = this.substr(0, 1);
                        var field = this.substr(1);
                        if (result.contentClassAttributes.hasOwnProperty(field)){
                            result.sortNameList.push({
                                'fieldName': result.contentClassAttributes[field].name[$.opendataTools.settings('language')],
                                'field': field,
                                'direction': direction === '+' ? 'Ascendente' : 'Discendente'
                            });
                        }
                    })
                }
            }
            if (value.length === 0){
                return result;
            }
            var parts = value.split('|');
            var slicePos = 0;
            $.each(parts, function (i,v){
                var part = this;
                if (part.indexOf("parent:") > -1){
                    result.parent = parseInt(part.substr(("parent:").length));
                    findParent(result.parent);
                    slicePos++;
                }
                if (part.indexOf("filters:") > -1){
                    result.filters = part.substr(("filters:").length);
                    slicePos++;
                }
                if (part.indexOf("group_by:") > -1){
                    result.group_by = part.substr(("group_by:").length);
                    slicePos++;
                }
                if (part.indexOf("order_by:") > -1){
                    result.order_by = part.substr(("order_by:").length).split(',');
                    slicePos++;
                }
            });
            if (slicePos > 0) {
                parts = parts.slice(slicePos);
            }
            $.each(parts, function (i,v){
                if (i === 0){
                    result.class = v;
                    findContentClass(result.class);
                }
                if (i === 1){
                    result.fields = v.split(',');
                    findFieldNameList(result.fields);
                }
                if (i === 2){
                    result.depth = parseInt(v);
                }
            });
            findSortNameList(result.order_by);
            findFilterNameList(result.filters);
            result.toString = function() {
                var parts = [];
                if (this.parent){
                    parts.push('parent:'+this.parent);
                }
                if (this.filters){
                    parts.push('filters:'+this.filters);
                }
                if (this.group_by){
                    parts.push('group_by:'+this.group_by);
                }
                if (this.order_by){
                    parts.push('order_by:'+this.order_by);
                }
                parts.push(this.class);
                parts.push(this.fields);
                if (this.depth){
                    parts.push(this.depth);
                }
                return parts.join('|');
            }
            return result;
        }

        $('[data-fields_gui]').each(function (){
            var container = $(this);
            var input = $('#'+container.data('fields_gui'));
            var template = $.templates('#tpl-fields-gui');
            var currentValue = input.val();

            var renderGui = function (fieldsQueryString) {
                var queryFields = stringQueryFieldsParser(fieldsQueryString);
                var renderData = $(template.render(queryFields));
                renderData.data('fieldsQueryString', queryFields.toString());
                renderData.data('fieldsObject', queryFields);
                renderData.find('[data-modify]').on('click', function (e){
                    var field = $(this).data('modify');
                    var itemContainer = $(this).parents('[data-fields_gui_item]');
                    var queryFields = itemContainer.data('fieldsObject');
                    itemContainer.find('[data-modify]').addClass('hide');
                    itemContainer.find('[data-cancel="'+field+'"]').removeClass('hide');
                    var fieldContainer = itemContainer.find('[data-'+field+']');

                    var form, formRows;
                    if (field === 'class'){
                        form = $('<div class="clearfix"></div>');
                        form.append($.templates('#tpl-class-select').render({
                            'current': queryFields.class
                        }));
                        form.append($.templates('#tpl-store-button').render({}));
                        fieldContainer.html(form).find('.store-field').on('click', function (ev){
                            $(this).hide();
                            var value = form.find('select').val();
                            if (value !== queryFields.class) {
                                queryFields.class = form.find('select').val();
                                queryFields.filters = null;
                                queryFields.fields = [];
                                queryFields.order_by = null;
                            }
                            itemContainer.replaceWith(renderGui(queryFields.toString()));
                            ev.preventDefault();
                        })
                    }else if (field === 'fields'){
                        form = $('<div class="clearfix"></div>');
                        form.append($.templates('#tpl-attribute-checkbox').render({
                            'current': queryFields.fields,
                            'contentClass': queryFields.contentClass
                        }));
                        form.append($.templates('#tpl-store-button').render({}));
                        fieldContainer.html(form).find('.store-field').on('click', function (ev){
                            $(this).hide();
                            var values = [];
                            fieldContainer.html(form).find('input:checked').each(function (){
                                values.push($(this).val());
                            })
                            if (values.length > 0) {
                                queryFields.fields = values;
                                var newOrderBy = [];
                                $.each(queryFields.order_by, function (){
                                    var direction = this.substr(0, 1);
                                    var field = this.substr(1);
                                    if ($.inArray(field, values) > 0){
                                        newOrderBy.push(this);
                                    }
                                });
                                queryFields.order_by = newOrderBy.join(',');
                            }
                            itemContainer.replaceWith(renderGui(queryFields.toString()));
                            ev.preventDefault();
                        })
                    }else if (field === 'order_by'){
                        var disabledFields = [];
                        $.each(queryFields.contentClass.fields, function (){
                            if ($.inArray(this.identifier, queryFields.fields) < 0){
                                disabledFields.push(this.identifier);
                            }
                        })
                        form = $('<div></div>');
                        formRows = $('<div class="item-form"></div>').appendTo(form);
                        $.each(queryFields.sortNameList, function (){
                            var row = $($.templates('#tpl-sort-item').render({
                                'current': this.field,
                                'contentClass': queryFields.contentClass,
                                'disabledFields': disabledFields,
                                'direction': this.direction
                            }));
                            row.find('.remove-field-item').on('click', function (ev){
                                $(this).parents('.sort-item').remove();
                                ev.preventDefault();
                            });
                            formRows.append(row)
                        })
                        form.append($.templates('#tpl-add-item-button').render({}));
                        form.append($.templates('#tpl-store-button').render({}));
                        fieldContainer.html(form);
                        fieldContainer.find('.add-field-item').on('click', function (ev){
                            var row = $($.templates('#tpl-sort-item').render({
                                'current': '',
                                'contentClass': queryFields.contentClass,
                                'disabledFields': disabledFields,
                                'direction': 'Ascendente'
                            }));
                            row.find('.remove-field-item').on('click', function (ev){
                                $(this).parents('.sort-item').remove();
                                ev.preventDefault();
                            });
                            fieldContainer.find('.item-form').append(row)
                            ev.preventDefault();
                        });
                        fieldContainer.find('.store-field').on('click', function (ev){
                            $(this).hide();
                            var sortList = [];
                            fieldContainer.find('.row').each(function (){
                                var field = $(this).find('.attribute-select').val();
                                var direction = $(this).find('.sort-direction').val();
                                if (field){
                                    var dir = direction === 'Ascendente' ? '+' : '-';
                                    if ($.inArray('+'+field, sortList) < 0 && $.inArray('-'+field, sortList) < 0) {
                                        sortList.push(dir + field);
                                    }
                                }
                            })
                            if (sortList.length > 0) {
                                queryFields.order_by = jQuery.unique(sortList).join(',');
                            }
                            itemContainer.replaceWith(renderGui(queryFields.toString()));
                            ev.preventDefault();
                        })

                    }else if (field === 'filters'){
                        form = $('<div></div>');
                        formRows = $('<div class="item-form"></div>').appendTo(form);
                        var appendRowEvents = function (row){
                            row.find('.remove-field-item').on('click', function (ev){
                                $(this).parents('.filter-item').remove();
                                ev.preventDefault();
                            });
                        };
                        $.each(queryFields.filterNameList, function (){
                            var tpl = this.fieldName ? '#tpl-filter-item' : '#tpl-custom-filter-item';
                            var row = $($.templates(tpl).render({
                                'current': this.field,
                                'value': this.value,
                                'operator': this.operator,
                                'contentClass': queryFields.contentClass
                            }));
                            appendRowEvents(row);
                            formRows.append(row)
                        })

                        form.append($.templates('#tpl-add-item-button').render({}));
                        form.append($.templates('#tpl-add-custom-item-button').render({}));
                        form.append($.templates('#tpl-store-button').render({}));
                        fieldContainer.html(form);
                        fieldContainer.find('.add-field-item').on('click', function (ev){
                            var row = $($.templates('#tpl-filter-item').render({
                                'current': null,
                                'value': '',
                                'operator': '',
                                'contentClass': queryFields.contentClass
                            }));
                            appendRowEvents(row);
                            fieldContainer.find('.item-form').append(row)
                            ev.preventDefault();
                        });
                        fieldContainer.find('.add-custom-field-item').on('click', function (ev){
                            var row = $($.templates('#tpl-custom-filter-item').render({
                                'current': null,
                                'value': '',
                                'operator': '',
                                'contentClass': queryFields.contentClass
                            }));
                            appendRowEvents(row);
                            fieldContainer.find('.item-form').append(row)
                            ev.preventDefault();
                        });
                        fieldContainer.find('.store-field').on('click', function (ev){
                            $(this).hide();
                            var sortList = [];
                            fieldContainer.find('.row').each(function (){

                            })
                            if (sortList.length > 0) {
                                queryFields.order_by = jQuery.unique(sortList).join(',');
                            }
                            itemContainer.replaceWith(renderGui(queryFields.toString()));
                            ev.preventDefault();
                        })
                    }
                    e.preventDefault();
                })
                renderData.find('[data-cancel]').on('click', function (e){
                    $(this).addClass('hide');
                    var field = $(this).data('cancel');
                    var itemContainer = $(this).parents('[data-fields_gui_item]');
                    itemContainer.find('[data-'+field+']').text('...')
                    itemContainer.find('[data-modify]').removeClass('hide');
                    itemContainer.replaceWith(renderGui(itemContainer.data('fieldsQueryString')));
                    e.preventDefault();
                });
                return renderData;
            }

            $.each(currentValue.split('&'), function (){
                var renderData = renderGui(this)
                container.append(renderData);
            })
        });
    })
</script>
{/literal}