<div class="panel-body" style="background: #fff">
    <form action="{concat('editorialstuff/action/', $factory_identifier, '/', $post.object_id, '#tab_mailing')|ezurl(no)}"
          enctype="multipart/form-data" method="post">

        {foreach $post.history as $time => $history_items}
            {foreach $history_items as $item}
                {if $item.action|eq('sent_to_mailing_list')}
                    <div class="alert alert-danger">
                        {if is_set($item.parameters.language)}
                            <img src="{$item.parameters.language|flag_icon}" alt="{$item.parameters.language|wash()}" />
                        {/if}
                        {'Content already sent at'} {$time|l10n( shortdatetime )}
                    </div>
                {/if}
            {/foreach}
        {/foreach}

        <div class="clearfix mb-3">
            <div class="row">
            {def $language_codes = $post.object.language_codes}
            {foreach $language_codes as $index => $language}
                <div class="col-sm-2 col-md-1">
                    <div class="form-group form-check">
                        <input type="radio" {if $index|eq(0)}checked{/if} value="{$language|wash()}" id="{$language|wash()}" name="ActionParameters[language]">
                        <label class="form-check-label" for="{$language|wash()}"><img src="{$language|flag_icon}" alt="{$language|wash()}" /></label>
                    </div>
                </div>
            {/foreach}
                <div class="col-3">
                    <button type="submit" name="ActionSendToMailingList" class="btn btn-success pull-left"
                            {if $post.is_published|not()}disabled{/if}>{'Send'|i18n('bootstrapitalia')}</button>
                    <input type="hidden" name="ActionIdentifier" value="ActionSendToMailingList"/>
                </div>
                <div class="col-sm-12 col-md-{12|sub(sum(3,count($language_codes)))} text-right">
                    <a class="btn btn-primary pull-right" href="{$post.mailing_list_url|ezurl(no)}">Mailing list</a>
                </div>
            </div>
            {undef $language_codes}
        </div>

        <div class="input-group mb-3">
            <div class="input-group-prepend">
                <div class="input-group-text">
                    <i class="fa fa-toggle-on" id="user-toggle"></i>
                </div>
            </div>
            <input type="text" id="user-search" class="form-control" placeholder="{'Search'|i18n('openpa/search')}"
                   aria-label="Find user">
        </div>

        <ul class="list-group" id="user-list">
            {foreach $post.mailing_list as $item}
                <li class="list-group-item">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" checked="checked" name="ActionParameters[users][]"
                               value="{$item.u_id}" id="user-{$item.u_id}">
                        <label class="form-check-label" for="user-{$item.u_id}">
                            <strong>{$item.last_name|wash()} {$item.first_name|wash()}</strong>
                            <small>{$item.email|wash()}</small>
                        </label>
                    </div>
                </li>
            {/foreach}
        </ul>
    </form>
</div>
{ezscript_require(array('jquery.quicksearch.js'))}
{literal}
    <script>
        $(document).ready(function () {
            $('#user-search').quicksearch('#user-list li');
            $('#user-toggle').on('click', function (e) {
                var self = $(this);
                var checkboxes = $('#user-list li input[type="checkbox"]');
                if (self.hasClass('fa-toggle-on')) {
                    self.removeClass('fa-toggle-on').addClass('fa-toggle-off');
                    checkboxes.attr('checked', false).trigger('change');
                } else {
                    self.removeClass('fa-toggle-off').addClass('fa-toggle-on');
                    checkboxes.attr('checked', true).trigger('change');
                }
            })
        })
    </script>
{/literal}