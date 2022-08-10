{ezpagedata_set('show_path', false())}

{def $attribute_default_category = ezini( 'ClassAttributeSettings', 'DefaultCategory', 'content.ini' )}

<div class="row">
    <div class="col-md-8 offset-md-2">

        {if $success}
            <div class="text-center py-5">
                <i aria-hidden="true" class="fa fa-check fa-5x"></i>
                <h3>Le informazioni sono state salvate e inviate per la validazione</h3>
                <h4>Quando saranno validate riceverai una mail all'indirizzo che hai specificato</h4>
            </div>
        {else}
            <h1>Crea il tuo account</h1>

            {if and(is_set($view_parameters.error), $view_parameters.error|eq('invalid_recaptcha'))}
                <div class="alert alert-danger">
                    <p>Antispam {'Input required.'|i18n( 'kernel/classes/datatypes' )}</p>
                </div>
            {/if}

            <form enctype="multipart/form-data" action="{concat("join/as/", $class_identifier)|ezurl(no)}" method="post"
                  name="AutoRegister"
                  class="form-signin">

                {if $validation.processed}
                    {if $validation.attributes|count|gt(0)}
                        <div class="alert alert-danger">
                            <ul>
                                {foreach $validation.attributes as $attribute}
                                    <li>{$attribute.name}: {$attribute.description}</li>
                                {/foreach}
                            </ul>
                        </div>
                    {/if}
                {/if}

                {if ezini_hasvariable( 'EditSettings', 'AdditionalTemplates', 'content.ini' )}
                    {foreach ezini( 'EditSettings', 'AdditionalTemplates', 'content.ini' ) as $additional_tpl}
                        {include uri=concat( 'design:', $additional_tpl )}
                    {/foreach}
                {/if}

                {if count($content_attributes)|gt(0)}
                    {def $bypass_captcha = false()}
                    {foreach $content_attributes as $attribute}
                        {def $class_attribute = $attribute.contentclass_attribute}

                        {if or(
                            and($class_attribute.is_required, $class_attribute.is_information_collector|not()),
                            and(or($class_attribute.category|eq(''),$class_attribute.category|eq($attribute_default_category)), $class_attribute.is_information_collector|not())
                        )}
                            <div id="edit-{$class_attribute.identifier}"
                                 class="py-3 mb-4 ezcca-edit-datatype-{$attribute.data_type_string} ezcca-edit-{$class_attribute.identifier}">
                                    {if $attribute.data_type_string|eq('ezboolean')}
                                        {def $placeholder_array = array()}
                                        {set $placeholder_array = $placeholder_array|append('<h5')}
                                        {if $attribute.has_validation_error}{set $placeholder_array = $placeholder_array|append(' class="text-danger"')}{else}{set $placeholder_array = $placeholder_array|append(' class="text-black"')}{/if}
                                        {set $placeholder_array = $placeholder_array|append('>')}
                                        {set $placeholder_array = $placeholder_array|append(first_set( $class_attribute.nameList[$content_language], $class_attribute.name )|wash)}
                                        {if $class_attribute.is_required}{set $placeholder_array = $placeholder_array|append('*')}{/if}
                                        {set $placeholder_array = $placeholder_array|append('</h5>')}
                                        {attribute_edit_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters html_class='form-control' placeholder=$placeholder_array|implode('')}
                                        {if $class_attribute.description}
                                            <small class="form-text text-muted mb-1">{first_set( $class_attribute.descriptionList[$content_language], $class_attribute.description)|wash}</small>
                                        {/if}
                                        {undef $placeholder_array}
                                    {else}
                                        <h5{if $attribute.has_validation_error} class="text-danger"{/if}>
                                            {first_set( $class_attribute.nameList[$content_language], $class_attribute.name )|wash}{if $class_attribute.is_required}*{/if}
                                        </h5>
                                        {if $class_attribute.description}
                                            <small class="form-text text-muted mb-1">{first_set( $class_attribute.descriptionList[$content_language], $class_attribute.description)|wash}</small>
                                        {/if}
                                        {attribute_edit_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters html_class='form-control'}
                                    {/if}
                                    <input type="hidden" name="ContentObjectAttribute_id[]" value="{$attribute.id}"/>
                            </div>
                            {if $class_attribute.data_type_string|eq('ocrecaptcha')}
                                {set $bypass_captcha = true()}
                            {/if}
                        {else}
                            <div style="display: none">
                                {attribute_edit_gui attribute_base=$attribute_base attribute=$attribute view_parameters=$view_parameters html_class='form-control'}
                            </div>
                        {/if}

                        {undef $class_attribute}
                    {/foreach}
                    <div class="">
                        {if $bypass_captcha|not}
                            <div class="py-3 mb-4">
                                <h5>Antispam</h5>
                                <small class="form-text text-muted mb-1">{'Confirm us that you are not a robot'|i18n( 'social_user/signup' )}</small>
                                {if $recaptcha_public_key|not()}
                                    <div class="message-warning">ReCAPTCHA API key not found</div>
                                {else}
                                    <div class="g-recaptcha" data-sitekey="{$recaptcha_public_key}"></div>
                                    <script type="text/javascript" src="https://www.recaptcha.net/recaptcha/api.js?hl={fetch( 'content', 'locale' ).country_code|downcase}"></script>
                                {/if}
                            </div>
                        {/if}
                        {undef $bypass_captcha}
                    </div>

                    <div class="clearfix">
                        <input class="btn btn-lg btn-success float-right" type="submit" name="RegisterButton" id="RegisterButton"
                               value="Salva"
                               onclick="window.setTimeout( disableButtons, 1 ); return true;"/>

                        <input class="btn btn-lg btn-dark" type="submit" name="CancelButton" id="CancelButton"
                               value="Annulla"
                               onclick="window.setTimeout( disableButtons, 1 ); return true;"/>
                    </div>
                {else}
                    <div class="alert alert-danger">
                        <p>{"Unable to register new user"|i18n("design/ocbootstrap/user/register")}</p>
                    </div>
                    <input class="btn btn-primary" type="submit" id="CancelButton" name="CancelButton"
                           value="Annulla"
                           onclick="window.setTimeout( disableButtons, 1 ); return true;"/>
                {/if}
            </form>
        {/if}
    </div>
</div>

{literal}
    <script type="text/javascript">
        function disableButtons() {
            document.getElementById('RegisterButton').disabled = true;
            document.getElementById('CancelButton').disabled = true;
        }
    </script>
{/literal}
