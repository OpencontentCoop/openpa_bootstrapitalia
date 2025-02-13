{if and(openpaini('Seo', 'CookieConsentMultimedia')|eq('enabled'), 
or($video.content|downcase|begins_with('https://www.youtube'),
$video.content|downcase|begins_with('https://youtu.be'),
$video.content|downcase|begins_with('https://m.youtube')))}
  <script>
  {literal}
  const loadVideo = function(videoId) {
    const videoEl = document.getElementById(videoId);
    const video = bootstrap.VideoPlayer.getOrCreateInstance(videoEl);
    const videoUrl = videoEl.getAttribute("data-video-url");
    video.setYouTubeVideo(videoUrl);
  }
  {/literal}
</script>
<div class="acceptoverlayable">
  <div class="acceptoverlay acceptoverlay-primary fade show">
    <div class="acceptoverlay-inner">
      <div class="acceptoverlay-icon">
        {display_icon('it-video', 'svg', 'icon icon-xl')}
      </div>
        <p>Accetta i cookie di terze parti per vedere il video.
          <a 
            class="text-white"
            role="button"
            href="#" 
            data-cc="show-preferencesModal">
            Gestisci le preferenze dei cookie
          </a>
        </p>
      <div class="acceptoverlay-buttons bg-dark">
        <button
          type="button"
          class="btn btn-primary"
          data-bs-accept-from="multimedia"
          onclick="loadVideo(`vid-{$video.id}`)">Accetta per questo video</button>
        <button
          type="button"
          class="btn btn-outline-primary"
          data-bs-accept-from="multimedia"
          data-cc="accept-all"
          onclick="loadVideo(`vid-{$video.id}`)">Accetta per tutti i video</button>
      </div>
    </div>
  </div>
  <div>
    <video controls data-bs-video id="vid-{$video.id}" data-video-url={$video.content}
      class="video-js"
      width="640" height="264">
    </video>
  </div>
</div>

{else}
  {def $oembed = get_oembed_object($video.content)}
  <div class="video-wrapper">{$oembed.html}</div>
  {undef $oembed}
{/if}
