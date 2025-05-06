{ezpagedata_set( 'show_path',false() )}
<style>.breadcrumb-container,.cmp-breadcrumbs{ldelim}display:none{rdelim}</style>

<div class="global-view-full">

    <h1 class="h3 pt-3">Impostazioni recaptcha</h1>

    {if is_set($message)}
        <div class="message-error">
            <p>{$message}</p>
        </div>
    {/if}

    <form method="post" action="{'openpa/recaptcha'|ezurl(no)}" class="form">

        <fieldset class="my-5">
            <h5>Chiavi Google ReCaptcha v2</h5>

            <div class="Form-field">
                <label class="Form-label" for="recaptcha">Chiave pubblica</label>
                <input id="recaptcha" class="Form-input u-color-black form-control box" type="text"
                       name="GoogleRecaptchaPublic" placeholder="Chiave pubblica" value="{$public|wash()}">
            </div>

            <div class="Form-field">
                <label class="Form-label" for="recaptcha2">Chiave privata</label>
                <input id="recaptcha2" class="Form-input u-color-black form-control box" type="text"
                       name="GoogleRecaptchaPrivate" placeholder="Chiave privata" value="{$private|wash()}">
            </div>
        </fieldset>

        <fieldset class="my-5">
            <h5>Chiavi Google ReCaptcha v3</h5>

            <div class="Form-field">
                <label class="Form-label" for="recaptcha">Chiave pubblica</label>
                <input id="recaptcha" class="Form-input u-color-black form-control box" type="text"
                       name="GoogleRecaptchaV3Public" placeholder="Chiave pubblica" value="{$publicV3|wash()}">
            </div>

            <div class="Form-field">
                <label class="Form-label" for="recaptcha2">Chiave privata</label>
                <input id="recaptcha2" class="Form-input u-color-black form-control box" type="text"
                       name="GoogleRecaptchaV3Private" placeholder="Chiave privata" value="{$privateV3|wash()}">
            </div>
        </fieldset>

        <input type="submit" class="defaultbutton btn btn-success" name="StoreSeo" value="Salva"/>
    </form>

</div>
