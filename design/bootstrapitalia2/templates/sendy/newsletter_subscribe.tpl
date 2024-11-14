{def $text_class = 'text-white'}
{def $id = ''}
{if is_set($text_default)}
    {set $text_class = ''}
{/if}
{if is_set($id_suffix)}
    {set $id = $id_suffix}
{/if}
<form id="sendy-subscribe{$id}" method="POST" accept-charset="utf-8" class="position-relative clearfix">

    <div class="form-group mb-0">
        <label class="{$text_class} font-weight-semibold active" for="email" style="transition: none 0s ease 0s; width: auto;">{"Enter your email"|i18n( 'openpa_newsletter' )}</label>
        <input type="email" name="email" id="email" class="form-control" placeholder="mail@example.com" required/>
    </div>

    {if ezini('SubscribeSettings', 'ListArray', 'sendy.ini')|count()|gt(0)}
        <div class="my-3">
            {foreach ezini('SubscribeSettings', 'ListArray', 'sendy.ini') as $idName}
                {def $list = $idName|explode(';')}
                <div class="form-group m-0">
                    <label class="{$text_class} font-weight-normal position-relative" for="list-{$list[0]|wash()}" style="padding-left: 20px;display: inline-block;line-height: 1.2">
                        <input type="checkbox" class="nl-list" id="list-{$list[0]|wash()}"
                               name="list[]" value="{$list[0]|wash()}"
                                {if ezini('SubscribeSettings', 'DefaultListId', 'sendy.ini')|eq($list[0])} checked="checked"{/if}
                               style="margin: 4px 0 0 -20px;"/>
                        {$list[1]|wash()}
                    </label>
                </div>
                {undef $list}
            {/foreach}
        </div>
    {else}
        <input type="hidden" name="list[]" value="{ezini('SubscribeSettings', 'DefaultListId', 'sendy.ini')}"/>
    {/if}

    {if ezini('SubscribeSettings', 'Gdpr', 'sendy.ini')|eq('true')}
        <div class="form-group my-3">
            <label class="{$text_class} font-weight-normal position-relative" for="gdpr" style="white-space: normal;font-size: 1em;padding-left: 20px;display: inline-block;line-height: 1.2">
                <input required="required" name="gdpr" type="checkbox" id="gdpr" class="position-absolute" style="margin: 4px 0 0 -20px;" />
                {"I certify that I have read and accept the %privacy_link_start%Privacy Statement%privacy_link_end%"|i18n('openpa_newsletter',,hash(
                '%privacy_link_start%', '<a href="#" data-toggle="modal" data-target="#informativa" data-bs-toggle="modal" data-bs-target="#informativa">',
                '%privacy_link_end%', '</a>'
                ))}
            </label>
        </div>

    {/if}
    <div style="display:none;"><label for="hp">HP</label><input type="text" name="hp" id="hp"/></div>

    <button class="btn btn-secondary btn-icon pull-right" type="submit">
        <svg class="icon icon-white" aria-hidden="true">
            {display_icon('it-mail', 'svg', 'icon icon-white')}
        </svg>
        <span>{"Subscribe"|i18n( 'openpa_newsletter' )}</span>
    </button>
</form>

<div id="informativa" class="modal fade font-sans-serif">
    <div class="modal-dialog modal-lg">
        <div class="card no-after">
            <div class="card-body">
                <div class="clearfix">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                </div>
                <div class="clearfix card-text text-sans-serif font-sans-serif">
                    {include uri='design:newsletter/informativa.tpl'}
                    <a class="btn btn-info pull-right" href="#" data-dismiss="modal" aria-hidden="true">{'Close'|i18n('bootstrapitalia')}</a>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    {literal}
    $(document).ready(function () {
      $('#sendy-subscribe{/literal}{$id}{literal}').on('submit', function (e) {
        var form = $(this);
        if ($('input.nl-list').length > 0 && $('input.nl-list:checked').length === 0) {
          e.preventDefault();
          return false;
        }
        var data = form.serializeArray();
        $.ez('newsletter::subscribe', data, function (response) {
          form.prepend('<div style="z-index: 10;min-height: 100%" class="position-absolute w-100 alert alert-dismissible fade show alert-'+response.code+' bg-white text-'+response.code+'">'+response.text+
            '<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button></div>');
        });
        e.preventDefault();
      });
    });
    {/literal}
</script>
<style>#informativa * {ldelim}color: #000 !important;{rdelim}</style>
