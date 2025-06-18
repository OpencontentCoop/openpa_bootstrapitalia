{def $languages=fetch('content', 'prioritized_languages')
     $object_language_codes=$object.language_codes
     $can_edit=true()}

<div class="container mt-5">
<div class="row">
  <div class="col-12 col-sm-6 offset-sm-3">

<form action={concat('content/edit/',$object.id)|ezurl} method="post">

{if $show_existing_languages}
    {* Translation a user is able to edit *}
    {set-block variable=$existing_languages_output}
    {foreach $languages as $language}
        {if $object_language_codes|contains($language.locale)}
            {if fetch('content', 'access', hash( 'access', 'edit',
                                                 'contentobject', $object,
                                                 'language', $language.locale ) )}
              <div class="form-check">
                <input id="show_existing_languages_output_{$language.locale}"
                       class="form-check-input"
                       type="radio"
                       name="EditLanguage"
                        {run-once} checked="checked"{/run-once}
                       value="{$language.locale}"/>
                <label class="form-check-label" for="show_existing_languages_output_{$language.locale}">{$language.name|wash}</label>
              </div>
            {/if}
        {/if}
    {/foreach}
    {/set-block}

    {if $existing_languages_output|trim}
        <h2>{'Existing languages'|i18n('design/ocbootstrap/content/edit_languages')}</h2>
        <div class="card card-body mt-3 mb-3">
          <h2 class="h5">{'Select the language you want to use when editing the object.'|i18n('design/ocbootstrap/content/edit_languages')}</h2>
            {$existing_languages_output}
        </div>
    {/if}
{/if}

{* Translation a user is able to create *}
{set-block variable=$nonexisting_languages_output}
{foreach $languages as $language}
    {if $object_language_codes|contains($language.locale)|not}
        {if fetch('content', 'access', hash( 'access', 'edit',
                                             'contentobject', $object,
                                             'language', $language.locale ) )}
            {if $language.name|ne('')}
              <div class="form-check">
                <input id="nonexisting_languages_output_{$language.locale}"
                       class="form-check-input"
                       type="radio"
                       name="EditLanguage"
                       {run-once} checked="checked"{/run-once}
                       value="{$language.locale}"/>
                <label class="form-check-label" for="nonexisting_languages_output_{$language.locale}">{$language.name|wash}</label>
              </div>
            {/if}
        {/if}
    {/if}
{/foreach}
{/set-block}

{if $nonexisting_languages_output|trim}
    <h1 class="h2">{'New languages'|i18n('design/ocbootstrap/content/edit_languages')}</h1>
    <div class="card card-body mt-3 mb-3">
        <h2 class="h5">{'Select the language you want to add to the object.'|i18n('design/ocbootstrap/content/edit_languages')}</h2>
        {$nonexisting_languages_output}
    </div>
    <div class="card card-body mb-3">
      <h2 class="h5">{'Select the language the new translation will be based on.'|i18n('design/ocbootstrap/content/edit_languages')}</h2>

      <div class="form-check">
        <input id="FromLanguage_null"
               class="form-check-input"
               type="radio"
               name="FromLanguage"
               checked="checked"
               value=""/>
        <label class="form-check-label" for="FromLanguage_null">{'Use an empty, untranslated draft'|i18n('design/ocbootstrap/content/edit_languages')}</label>
      </div>

      {foreach $object.languages as $language}
        <div class="form-check">
          <input id="FromLanguage_{$language.locale}"
                 class="form-check-input"
                 type="radio"
                 name="FromLanguage"
                 checked="checked"
                 value="{$language.locale}"/>
          <label class="form-check-label" for="FromLanguage_{$language.locale}">{$language.name|wash}</label>
        </div>
      {/foreach}
    </div>
{else}
    {if $show_existing_languages|not}
        {set $can_edit=false()}
        <div class="alert alert-warning mt-1 mb-3">
            {'You do not have permission to create a translation in another language.'|i18n('design/ocbootstrap/content/edit_languages')}
        </div>

        {* Translation a user is able to edit *}
        {set-block variable=$existing_languages_output}
        {foreach $languages as $language}
            {if $object_language_codes|contains($language.locale)}
                {if fetch('content', 'access', hash( 'access', 'edit',
                                                     'contentobject', $object,
                                                     'language', $language.locale ) )}
                  <div class="form-check">
                    <input id="existing_languages_output_{$language.locale}"
                           class="form-check-input"
                           type="radio"
                           name="EditLanguage"
                            {run-once} checked="checked"{/run-once}
                           value="{$language.locale}"/>
                    <label class="form-check-label" for="existing_languages_output_{$language.locale}">{$language.name|wash}</label>
                  </div>
                {/if}
            {/if}
        {/foreach}
        {/set-block}

        {if $existing_languages_output|trim}
            {set $can_edit=true()}
            <h2 class="h5">{'Existing languages'|i18n('design/ocbootstrap/content/edit_languages')}</h2>
            <div class="card card-body mb-3">
                <p>{'However, you can select one of the following languages for editing.'|i18n('design/ocbootstrap/content/edit_languages')}</p>
                {$existing_languages_output}
            </div>
        {/if}
    {elseif $existing_languages_output|trim|not}
        {set $can_edit=false()}
        <div class="alert alert-warning mt-1 mb-3">
          {'You do not have permission to edit the object in any available languages.'|i18n('design/ocbootstrap/content/edit_languages')}
        </div>
    {/if}
{/if}

<div class="clearfix mb-3">
    <input class="btn btn-dark float-left" type="submit" name="CancelDraftButton" value="{'Cancel'|i18n('design/ocbootstrap/content/edit_languages')}" />
    {if $can_edit}
        <input class="btn btn-success float-right" type="submit" name="LanguageSelection" value="{'Edit'|i18n('design/ocbootstrap/content/edit_languages')}" />
    {/if}
</div>

</form>
  </div>
</div>
</div>