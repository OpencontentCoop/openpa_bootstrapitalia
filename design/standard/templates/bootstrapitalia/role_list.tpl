{ezpagedata_set('show_path', false())}
<div class="row">
    <div class="col-12">
        <a class="btn btn-success rounded-0 float-right" href="#" id="AddRoleTag" data-root="{$root_tag.id}">
            Crea nuovo
        </a>
        <h3>
            {$root_tag.keyword|wash()}
            <a class="btn btn-xs btn-primary rounded-0" href="{'openpa/roles'|ezurl(no)}">
                Gestione ruoli amministrativi
            </a>
        </h3>
        <table class="table table-striped mt-4">
            <tr>
            {foreach ezini('RegionalSettings','SiteLanguageList') as $language}
                <th>
                    <img style="width: 30px;max-width:none" src="/share/icons/flags/{$language}.gif" />
                </th>
            {/foreach}
                <th>{'Synonyms'|i18n( 'extension/eztags/tags/view' )}</th>
                <th></th>
            </tr>
        {foreach $root_tag.children as $tag}
            <tr>
                {foreach ezini('RegionalSettings','SiteLanguageList') as $language}
                    {def $has_translation = false()}
                    {foreach $tag.translations as $translation}
                        {if $translation.locale|eq($language)}
                            <td>{$translation.keyword|wash()}</td>
                            {set $has_translation = true()}
                        {/if}
                    {/foreach}
                    {if $has_translation|not()}
                    <td></td>
                    {/if}
                    {undef $has_translation}
                {/foreach}
                <td>
                    <ul class="list-unstyled">
                    {foreach $tag.synonyms as $synonym}
                        <li>
                            <img src="/share/icons/flags/{$synonym.current_language}.gif" />
                            {$synonym.keyword|wash()}
                        </li>
                    {/foreach}
                    </ul>
                </td>
                <td>
                    <a href="#" data-tag="{$tag.id}" data-root="{$root_tag.id}">
                        <span class="fa-stack">
                            <i aria-hidden="true" class="fa fa-square fa-stack-2x"></i>
                            <i aria-hidden="true" class="fa fa-pencil fa-stack-1x fa-inverse"></i>
                        </span>
                    </a>
                </td>
            </tr>
        {/foreach}
        </table>
    </div>
</div>

<div id="data-modal" class="modal fade modal-fullscreen" data-backdrop="static" style="z-index:10000">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-body">
                <div class="clearfix">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true" aria-label="{'Close'|i18n('bootstrapitalia')}" title="{'Close'|i18n('bootstrapitalia')}">&times;</button>
                </div>
                <div id="data-form" class="clearfix p-4"></div>
            </div>
        </div>
    </div>
</div>

{ezscript_require(array(
    'jsrender.js',
    'handlebars.min.js',
    'alpaca.js',
    'jquery.opendataform.js'
))}
{ezcss_require(array(
    'alpaca.min.css',
    'alpaca-custom.css'
))}
<script>
{literal}
$(document).ready(function () {
    var FormSelector = "#data-form";
    var ModalSelector = "#data-modal";
    $('#AddRoleTag').on('click', function (e) {
        var self = $(this);
        $(FormSelector).opendataForm({
                root_tag: self.data('root')
            }, {
                connector: 'role_tag',
                onBeforeCreate: function () {
                    $(ModalSelector).modal('show');
                },
                onSuccess: function () {
                    $(ModalSelector).find('.modal-body').html('<p class="text-center mt-5"><i class="fa fa-spinner fa-spin fa-3x fa-fw"></i></p>');
                    location.reload();
                }
            }
        );
        e.preventDefault();
    });
    $('[data-tag]').on('click', function (e) {
        var self = $(this);
        $(FormSelector).opendataForm({
                root_tag: self.data('root'),
                current_tag: self.data('tag')
            }, {
                connector: 'role_tag',
                onBeforeCreate: function () {
                    $(ModalSelector).modal('show');
                },
                onSuccess: function () {
                    $(ModalSelector).find('.modal-body').html('<p class="text-center mt-5"><i class="fa fa-spinner fa-spin fa-3x fa-fw"></i></p>');
                    location.reload();
                }
            }
        );
        e.preventDefault();
    });
});
{/literal}
</script>