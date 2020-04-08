{def $oembed = get_oembed_object($attribute.content)}
{if is_set($oembed.html)}
     <div class="video-wrapper my-4">
          <div class="video-container">
               {$oembed.html}
          </div>
     </div>
{elseif count($attribute.content|explode( '?access_token' ))|gt(0)}
     {def $link = $attribute.content|explode( '?access_token' )|implode( 'embed/?access_token' )}
     <iframe style="border:0px;padding:0px;margin:0px;" width="100%" height="343" src="{$link}" frameborder="0" scrolling="no" allowfullscreen></iframe>
     {undef $link}
{elseif $attribute.data_text}
     <a href="{$attribute.content|wash( xhtml )}">{$attribute.data_text|wash( xhtml )}</a>
{else}
     <a href="{$attribute.content|wash( xhtml )}">{$attribute.content|wash( xhtml )}</a>
{/if}
