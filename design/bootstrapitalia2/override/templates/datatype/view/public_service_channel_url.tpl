{set_defaults(hash(
     'css_class', 'btn btn-primary fw-bold font-sans-serif',
     'secondary_css_class', 'btn btn-outline-primary',
     'context', false(),
     'service', false()
))}

{if $service}
     {def $service_widget_url_info = service_widget_url_info($attribute, $service)}

     <a class="{$css_class}" href="{$service_widget_url_info.url}">{$service_widget_url_info.text|wash( xhtml )}</a>

     {if and($service_widget_url_info.builtin|eq('inefficiency'), $context|eq('main'))}
          {def $inefficiency_dataset = fetch(content, object, hash(remote_id, 'inefficiency-dataset'))}
          {if and($inefficiency_dataset, $inefficiency_dataset.can_read)}
            <a class="ms-2 mr-2 {$secondary_css_class}"
              href="{$inefficiency_dataset.main_node.url_alias|ezurl(no)}">
                {$inefficiency_dataset.name|wash()}
            </a>
          {/if}
          {undef $inefficiency_dataset}
     {/if}

     {undef $service_widget_url_info}

{else}

     {def $is_channel = cond($attribute.object.class_identifier|eq('channel'), true(), false())}
     {if $attribute.data_text}
          <a class="{$css_class}"
            {if $is_channel|not()}target="_blank" rel="noopener noreferrer"{/if}
            href="{$attribute.content|wash( xhtml )}">
              {$attribute.data_text|wash( xhtml )}{if $is_channel|not()} <i class="fa fa-external-link"></i>{/if}
          </a>
     {else}
          <a class="{$css_class}"
            {if $is_channel|not()}target="_blank" rel="noopener noreferrer"{/if}
            href="{$attribute.content|wash( xhtml )}">
              {$attribute.content|wash( xhtml )}{if $is_channel|not()} <i class="fa fa-external-link"></i>{/if}
          </a>
     {/if}

{/if}

{unset_defaults(array('css_class', 'secondary_css_class', 'context', 'service'))}