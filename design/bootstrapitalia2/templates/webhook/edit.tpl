<section class="hgroup">
    <h1>
        {if $id|eq('new')}
            {'Create webhook'|i18n( 'extension/ocwebhookserver' )}
        {else}
            {'Edit webhook'|i18n( 'extension/ocwebhookserver' )}
        {/if}
    </h1>
</section>

{if is_set( $error_message )}
    <div class="alert alert-danger">
        <h4>{'Input did not validate'|i18n( 'design/admin/settings' )}</h4>
        <p>{$error_message}</p>
    </div>
{/if}

<form class="form" action="{concat('/webhook/edit/', $id)|ezurl(no)}" method="post">
    <div class="row mb-2">
        <div class="col-md-2 text-right font-weight-bold">
            <label for="name">{"Name"|i18n( 'extension/ocwebhookserver' )}</label>
        </div>
        <div class="col-md-8">
            <input required="required" class="form-control border" id="name" type="text" name="name"
                   value="{$webhook.name|wash()}"/>
        </div>
    </div>
    <div class="row mb-2">
        <div class="col-md-2 text-right font-weight-bold">
            <label for="url">{"Endpoint"|i18n( 'extension/ocwebhookserver' )}</label>
        </div>
        <div class="col-md-8">
            <input required="required" class="form-control border" id="url" type="text" name="url"
                   value="{if $webhook.url|ne('')}{$webhook.url|urldecode()|wash()}{/if}"/>
        </div>
    </div>
    <div class="row mb-2">
        <div class="col-md-2 text-right font-weight-bold">
            <label for="method">{"Method"|i18n( 'extension/ocwebhookserver' )}</label>
        </div>
        <div class="col-md-8">
            <input required="required" class="form-control border" id="method" type="text" name="method"
                   value="{if $webhook.method|ne('')}{$webhook.method|wash()}{else}POST{/if}"/>
        </div>
    </div>
    <div class="row mb-2">
        <div class="col-md-2 text-right font-weight-bold">
            <label for="secret">{"Secret"|i18n( 'extension/ocwebhookserver' )}</label>
        </div>
        <div class="col-md-8">
            <input class="form-control border" id="secret" type="text" name="secret" value="{$webhook.secret|wash()}"/>
        </div>
    </div>
    <div class="row mb-2">
        <div class="col-md-2 text-right font-weight-bold">
            <label>{"Triggers"|i18n( 'extension/ocwebhookserver' )}</label>
        </div>
        <div class="col-md-8">
            <div class="row">
            {foreach $triggers as $trigger}
                <div class="col-md-6">
                    <label class="checkbox">
                        <input {if $trigger.can_enabled|not}disabled="disabled"{/if} type="checkbox" name="triggers[{$trigger.identifier}]" value="1"
                               {if is_set($webhook_triggers[$trigger.identifier])}checked="checked"{/if} />
                        <strong>{$trigger.name|wash()}</strong>
                        <br /><small>{$trigger.description|wash()|autolink()}</small>
                    </label>
                    {if $trigger.use_filter}
                        {if and(is_set($webhook_triggers[$trigger.identifier]), $webhook_triggers[$trigger.identifier].filters|ne(''))}
                            <a href="#" data-schema='{$trigger.use_filter}' data-trigger="{$trigger.identifier}" class="btn btn-primary btn-xs ml-3">{"Edit filters"|i18n( 'extension/ocwebhookserver' )}</a>
                        {else}
                            <a href="#" data-schema='{$trigger.use_filter}' data-trigger="{$trigger.identifier}" class="btn btn-default btn-xs  ml-3">{"Set filters"|i18n( 'extension/ocwebhookserver' )}</a>
                        {/if}
                        <input type="hidden" data-filter_value="{$trigger.identifier}" value="{if is_set($webhook_triggers[$trigger.identifier])}{$webhook_triggers[$trigger.identifier].filters|wash()}{/if}" name="trigger_filters[{$trigger.identifier}]" />
                    {/if}
                </div>
                {delimiter modulo=2}</div><div class="row">{/delimiter}
            {/foreach}
            </div>
        </div>
    </div>
    <div class="row mb-2">
        <div class="col-md-2 text-right font-weight-bold">
            <label for="headers">{"Headers"|i18n( 'extension/ocwebhookserver' )}</label>
        </div>
        <div class="col-md-8">
            <textarea class="form-control border" id="headers" name="headers">{$webhook.headers_array|implode("\n")}</textarea>
        </div>
    </div>
    {if $can_customize_payload}
        <div class="row mb-2">
            <div class="col-md-2 text-right font-weight-bold">
            <label>{"Payload"|i18n( 'extension/ocwebhookserver' )}</label>
        </div>
        <div class="col-md-8">
            <label class="checkbox">
                <input type="checkbox" data-payload_editor value="1" {if $webhook.payload_params|eq('')}checked="checked"{/if} />
                {"Use default payload"|i18n( 'extension/ocwebhookserver' )}
            </label>

            <div id="payload_editor" class="row" {if $webhook.payload_params|eq('')}style="display: none"{/if}>
                <div class="col-md-8">
                    <label for="payload_params">Custom payload</label>
                    <p class="text-muted">{'Type Ctrl+L to format and validate the JSON string.'|i18n( 'extension/ocwebhookserver' )}</p>
                    <p class="text-danger"></p>
                    <textarea class="form-control" id="payload_params" rows="15" name="payload_params">{$webhook.payload_params}</textarea>
                    {foreach $help_texts as $help_text}{$help_text}{/foreach}
                </div>
                <div class="col-md-4">
                    <label style="display: block">Available placeholders</label>
                    {foreach $payload_placeholders as $placeholder}
                        <a style="margin: 2px" href="#" data-payload_placeholder class="btn btn-xs btn-default">{$placeholder|wash()}</a>
                    {/foreach}
                </div>
            </div>
        </div>
    </div>
    {/if}
    <div class="row mb-2">
        <div class="col-md-8 offset-md-2">
            <label class="checkbox">
                <input type="checkbox" name="enabled" value="1" {if $webhook.enabled|eq(1)}checked="checked"{/if} />
                {"Enable"|i18n( 'extension/ocwebhookserver' )}
            </label>
        </div>
    </div>
    <div class="row mb-2">
        <div class="col-md-8 offset-md-2">
            <label class="checkbox">
                <input type="checkbox" name="retry_enabled" value="1" {if $webhook.retry_enabled|eq(1)}checked="checked"{/if} />
                {"Enable retries on failure"|i18n( 'extension/ocwebhookserver' )}
            </label>
        </div>
    </div>
    <div class="row mb-2">
        <div class="col-md-11 text-right">
            <input class="btn btn-lg btn-success" type="submit" name="Store"
                   value="{'Store webhook'|i18n( 'extension/ocwebhookserver' )}"/>
        </div>
    </div>

</form>


{ezscript_require(array(
    'ezjsc::jquery',
    'ezjsc::jqueryUI',
    'moment-with-locales.min.js',
    'handlebars.min.js',
    'bootstrap-datetimepicker.min.js',
    'alpaca.min.js'
))}
{ezcss_load(array(
    'alpaca.min.css',
    'bootstrap-datetimepicker.min.css'
))}
<div id="modal" class="modal fade">
	<div class="modal-dialog modal-lg">
		<div class="modal-content">
			<div class="modal-body">
				<div class="clearfix">
					<button type="button" class="close" data-bs-dismiss="modal" aria-hidden="true">&times;</button>
				</div>
				<div id="filters-form" class="clearfix"></div>
			</div>
		</div>
	</div>
</div>

{literal}
<script type="text/javascript">
    $(document).ready(function () {
        var modal = $('#modal');
        var payloadEditor = $('#payload_editor');
        var payloadText = payloadEditor.find('textarea');

        var validateAndFormatPayloadText = function (){
            try
            {
                var value = payloadText.val();
                if (value.length === 0){
                    return true;
                }
                // format the string as well
                var obj = JSON.parse(value);
                payloadText.val(JSON.stringify(obj, null, 3));
                payloadEditor.find('.text-danger').html('');

                return true;
            }
            catch(e)
            {
                payloadEditor.find('.text-danger').html(e.message);

                return false;
            }
        };

        payloadText.on('keypress', function(e) {
            var code = e.keyCode || e.wich;
            if (code === 34) {
                payloadText.insertAtCaret('"');
            }
            if (code === 123) {
                payloadText.insertAtCaret('}');
            }
            if (code === 91) {
                payloadText.insertAtCaret(']');
            }
        }).on('keydown', function(e) {
            if ((e.metaKey || e.ctrlKey) && ( String.fromCharCode(e.which).toLowerCase() === 'l') ) {
                validateAndFormatPayloadText();
            }
        });
        $('[data-payload_placeholder]').on('click', function (e) {
            payloadText.insertAtCaret($(this).text());
            e.preventDefault();
        });
        $('[data-payload_editor]').on('click', function (e) {
            if ($(this).is(':checked')){
                payloadText.val('');
                payloadEditor.find('.text-danger').html('')
                payloadEditor.hide();
            }else{
                payloadEditor.show();
            }
        });
        validateAndFormatPayloadText();
        $('[data-trigger]').on('click', function (e) {
            modal.modal('show');
            var self = $(this);
            var trigger = self.data('trigger');
            var input = $('[data-filter_value="'+trigger+'"]');

            $("#filters-form").alpaca('destroy').alpaca($.extend(true, $(this).data('schema'),{
                "data": input.val().length > 0 ? JSON.parse(input.val()) : null,
                "options": {
                    "form": {
                        "buttons": {
                            "submit": {
                                "click": function() {
                                    this.refreshValidationState(true);
                                    if (this.isValid(true)) {
                                        var value = this.getValue();
                                        if ($.isEmptyObject(value)){
                                            self.html('{/literal}{"Set filters"|i18n('extension/ocwebhookserver')}{literal}').addClass('btn-default').removeClass('btn-primary');
                                            input.val('');
                                        }else{
                                            self.html('{/literal}{"Edit filters"|i18n('extension/ocwebhookserver')}{literal}').addClass('btn-primary').removeClass('btn-default');
                                            input.val(JSON.stringify(value));
                                        }
                                        modal.modal('hide');
                                    }
                                },
                                'id': "save-button",
                                "value": "Save",
                                "styles": "btn btn-md btn-success pull-right"
                            }
                        }
                    }
                }
            }));
            e.preventDefault();
        });

        var library = {};
        library.json = {
            replacer: function(match, pIndent, pKey, pVal, pEnd) {
                var key = '<span class=json-key>';
                var val = '<span class=json-value>';
                var str = '<span class=json-string>';
                var r = pIndent || '';
                if (pKey)
                    r = r + key + pKey.replace(/[": ]/g, '') + '</span>: ';
                if (pVal)
                    r = r + (pVal[0] === '"' ? str : val) + pVal + '</span>';
                return r + (pEnd || '');
            },
            prettyPrint: function(obj) {
                var jsonLine = /^( *)("[\w]+": )?("[^"]*"|[\w.+-]*)?([,[{])?$/mg;
                return JSON.stringify(obj, null, 3)
                    .replace(/&/g, '&amp;').replace(/\\"/g, '&quot;')
                    .replace(/</g, '&lt;').replace(/>/g, '&gt;')
                    .replace(jsonLine, library.json.replacer);
            }
        };

        $('code.json').each(function () {
            try {
                var tmpData = JSON.parse($(this).text());
                $(this).html(library.json.prettyPrint(tmpData));
            } catch (e) {
                $(this).parent().css({'white-space':'normal'});
                console.log(e);
            }
        });
    });
</script>
{/literal}