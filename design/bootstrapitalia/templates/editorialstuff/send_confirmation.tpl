<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    {include uri='design:page_head_style.tpl' theme=default}
</head>

<body>
<div class="container my-5">
    <form action="{concat('editorialstuff/action/', $factory_identifier, '/', $post.object_id, '#tab_mailing')|ezurl(no)}" method="post">

        <div class="row">
            <div class="col">
                <h4>Confermi l'invio della notifica mail del contenuto <em>{$post.object.name|wash}</em> ai seguenti indirizzi:</h4>
                <ul class="list-inline">
                    {foreach $emails as $id => $email}
                        <li class="list-inline-item">
                            {$email|wash()}
                            <input type="hidden" checked="checked" name="ActionParameters[users][]" value="{$id|wash()}">
                        </li>
                    {/foreach}
                </ul>
                <input type="hidden" value="{$language|wash()}" name="ActionParameters[language]">
                <a class="btn btn-danger pull-left" href="{$post.editorial_url|ezurl(no)}">{'Cancel'|i18n('opendata_forms')}</a>
                <button type="submit" name="ActionDoSendToMailingList" class="btn btn-success pull-right">{'Send'|i18n('bootstrapitalia')}</button>
                <input type="hidden" name="ActionIdentifier" value="ActionDoSendToMailingList"/>
                {if is_set($token)}
                    <input type="hidden" name="{$token_field|wash()}" value="{$token|wash()}"/>
                {/if}
            </div>
        </div>
    </form>
</div>

{* This comment will be replaced with actual debug report (if debug is on). *}
<!--DEBUG_REPORT-->
</body>
</html>
