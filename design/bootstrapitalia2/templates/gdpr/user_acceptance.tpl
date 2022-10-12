<div class="mb-3 text-sans-serif">
    <form action="{'gdpr/user_acceptance/'|ezurl('no')}" method="post">

        <div class="row">
            <div class="col">
                <h2>{$attribute.contentclass_attribute_name|wash()}</h2>
                {attribute_edit_gui attribute=$attribute}
            </div>
        </div>

        <div class="row">
            <div class="col text-right">
                <input class="btn btn-success" type="submit" value="{'Save'|i18n( 'design/admin/settings' )}" />
            </div>
        </div>
    </form>
</div>
{include uri='design:page_footer_script.tpl'}