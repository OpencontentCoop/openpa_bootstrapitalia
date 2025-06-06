{set $classification = cond( and(is_set( $align ), $align ), concat( $classification, ' text-', $align ), $classification )}
{set $classification = concat($classification, ' font-sans-serif title_editor')}
{if is_set($anchor_name)}<a name={$anchor_name} />{/if}
<a id="eztoc{$toc_anchor_name}"></a>
{switch name=sw match=$level}
{case match=1}
<h3{if $classification|trim} class="{$classification|wash}"{/if}>{$content}</h3>
{/case}
{case match=2}
<h4{if $classification|trim} class="{$classification|wash}"{/if}>{$content}</h4>
{/case}
{case match=3}
<h5{if $classification|trim} class="{$classification|wash}"{/if}>{$content}</h5>
{/case}
{case match=4}
<h6{if $classification|trim} class="{$classification|wash}"{/if}>{$content}</h6>
{/case}
{case match=5}
<h6{if $classification|trim} class="{$classification|wash}"{/if}>{$content}</h6>
{/case}
{case match=6} {* html does not have h7 *}
<h6{if $classification|trim} class="{$classification|wash}"{/if}>{$content}</h6>
{/case}
{case}
<h3{if $classification|trim} class="{$classification|wash}"{/if}>{$content}</h3>
{/case}
{/switch}
