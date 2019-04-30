{def $oembed = get_oembed_object($attribute.data_text)}
{if is_set($oembed.html)}
     <div class="video-wrapper my-4">
          <div class="video-container">
               {$oembed.html}
          </div>
     </div>
{elseif count($attribute.data_text|explode( '?access_token' ))|gt(0)}
     {def $link = $attribute.data_text|explode( '?access_token' )|implode( 'embed/?access_token' )}
     <iframe style="border:0px;padding:0px;margin:0px;" width="100%" height="343" src="{$link}" frameborder="0" scrolling="no" allowfullscreen></iframe>
     {undef $link}
{/if}