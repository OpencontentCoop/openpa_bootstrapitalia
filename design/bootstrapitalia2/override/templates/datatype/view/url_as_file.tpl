<div class="card-wrapper card-column my-3">
      <div class="font-sans-serif card card-teaser card-teaser-info rounded shadow-sm p-3 card-teaser-info-width mt-0 mb-3">
          {display_icon('it-link', 'svg', 'icon')}
          <div class="card-body">
              <h5 class="card-title">
                  <a class="stretched-link" href="{$attribute.content|wash( xhtml )}" title="{'Go to content'|i18n('bootstrapitalia')}">
                      {if $attribute.data_text}{$attribute.data_text|wash( xhtml )}{else}{$attribute.content|wash( xhtml )}{/if}
                  </a>
                  {if $attribute.data_text}<small class="text-truncate d-block" style="max-width: 250px;">{$attribute.content|wash( xhtml )}</small>{/if}
              </h5>
          </div>
      </div>
  </div>