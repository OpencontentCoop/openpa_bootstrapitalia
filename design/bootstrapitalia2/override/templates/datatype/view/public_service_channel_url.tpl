{set_defaults(hash(
     'css_class', 'btn btn-primary fw-bold font-sans-serif',
     'secondary_css_class', 'btn btn-outline-primary',
     'context', false(),
     'service', false()
))}

{def $service_widget_url_info = service_widget_url_info($attribute, $service)}

<a class="{$css_class}" href="{$service_widget_url_info.url}">{$service_widget_url_info.text|wash( xhtml )}</a>

{if and($service_widget_url_info.builtin|eq('inefficiency'), $context|eq('main'))}
     {def $inefficiency_dataset = fetch(content, object, hash(remote_id, 'inefficiency-dataset'))}
     {if $inefficiency_dataset}
     <a class="ms-2 mr-2 {$secondary_css_class}" href="{$inefficiency_dataset.main_node.url_alias|ezurl(no)}">{$inefficiency_dataset.name|wash()}</a>
     {/if}
     {undef $inefficiency_dataset}
{/if}

{undef $service_widget_url_info}
{unset_defaults(array('css_class', 'secondary_css_class', 'context', 'service'))}