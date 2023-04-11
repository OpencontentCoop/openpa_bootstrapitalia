{def $flash_node = $block.valid_nodes[0]}
{if or(is_set($flash_node.data_map.ezflowmedia),is_set($flash_node.data_map.media))}
  {def $siteurl = concat( "http://", ezini( 'SiteSettings', 'SiteURL' ) )  
       $attribute = cond( is_set($flash_node.data_map.ezflowmedia), $flash_node.data_map.ezflowmedia, $flash_node.data_map.media)
       $video = concat("content/download/", $attribute.contentobject_id, "/", $attribute.content.contentobject_attribute_id)|ezurl(no)
       $width='100%'
       $height='180px'
       $sottotitoli = false()}
  {if is_set( $flash_node.data_map.sottotitoli )}
      {if $flash_node.data_map.sottotitoli.has_content}
          {set $sottotitoli = concat("content/download/",$flash_node.data_map.sottotitoli.contentobject_id,"/",$flash_node.data_map.sottotitoli.content.contentobject_attribute_id,"/",$flash_node.data_map.sottotitoli.content.original_filename)|ezurl}
      {/if}
  {/if}
<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">

  {if $block.name|ne('')}
      <h3 class="openpa-widget-title"><span>{$block.name|wash()}</span></h3>
  {else}
      <h3 class="openpa-widget-title"><a title="{$flash_node.name|wash()}" href={$flash_node.url_alias|ezurl}>{$flash_node.name|shorten(73)|wash()}</a></h3>
  {/if}

<div class="openpa-widget-content">
  
  {if $flash_node|has_attribute('cover')}	
    {def $image_content = $flash_node.data_map.cover.content}
    {if $image_content.is_valid}
      {def $image = $image_content['ezflowmediablock']}	
    {/if}
  
  {elseif $flash_node|has_attribute('image')}	
    {def $image_content = $flash_node.data_map.image.content}
    {if $image_content.is_valid}
      {def $image = $image_content['ezflowmediablock']}	
    {/if}
  
  {elseif $flash_node.parent|has_attribute('image')}	
    {def $image_content = $flash_node.parent.data_map.image.content}
    {if $image_content.is_valid}
      {def $image = $image_content['ezflowmediablock']}
    {elseif $flash_node|has_attribute('image')}	
      {def $image_content = $flash_node.data_map.image.content}
      {if $image_content.is_valid}
        {def $image = $image_content['ezflowmediablock']}
      {/if}
    {/if}
  {/if}
  
      <div class="webtv-content">
          {if $attribute.has_content}
            {if $image}
                {def $style = concat( 'display:block;width:', $width, ';height:', $height, ';background-image:url(', $image.url|ezurl(no), ')' ) }
            {else}
                {def $style = concat( 'display:block;width:', $width, ';height:', $height, ';' )}        
            {/if}
            {include name=video_player uri="design:content/mediaplayer/video_player.tpl" attribute=$attribute params=hash( 'style', $style, 'image', 'icons/logo-player.png' )}
          {elseif $flash_node|has_attribute('descrizione')}
            {$flash_node|attribute('descrizione').content.output.output_text|autoembed(array('<div class="video-wrapper"><div class="video-container">', '</div></div>'))}          
          {/if}
      </div>
      
      <a class="readmore" title="Entra nella sezione specifica {$flash_node.parent.name}" href={$flash_node.parent.url_alias|ezurl()}>
        Entra in {$flash_node.parent.name}
      </a>


  </div>
  </div>
{/if}  
{undef}
