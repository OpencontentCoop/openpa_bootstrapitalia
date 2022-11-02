{def $icon_labels = class_extra_parameters($node.object.class_identifier, 'bootstrapitalia_icon').icon_label
     $label = false()}
{foreach $icon_labels as $identifier}
    {if $node|has_attribute($identifier)}
        {foreach $node|attribute($identifier).content.tags as $tag}
            {set $label = $tag.keyword|wash}
            {break}
        {/foreach}
        {break}
    {/if}
{/foreach}
{if $label}{$label}{else}{$fallback|wash()}{/if}
{undef $icon_labels $label}