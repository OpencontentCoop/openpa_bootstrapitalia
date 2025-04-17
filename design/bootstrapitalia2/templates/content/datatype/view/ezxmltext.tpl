{if and(is_set($avoid_oembed), $avoid_oembed)}
  {$attribute.content.output.output_text}
{else}
  {$attribute.content.output.output_text|autoembed(array('<div class="video-wrapper my-4"><div class="video-container">', '</div></div>'))}
{/if}