{def $youtube_video = false()}
{if or($video.content|downcase|begins_with('https://www.youtube'),
  $video.content|downcase|begins_with('https://youtu.be'),
  $video.content|downcase|begins_with('https://m.youtube'))}
  {set $youtube_video = true()}
{/if}

{if and(openpaini('CookiesSettings', 'Consent', 'advanced')|eq('advanced'),
openpaini('Seo', 'CookieConsentMultimedia')|eq('enabled'),
$youtube_video)}
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
      <p>{'Accept third-party cookies to watch the video'|i18n('bootstrapitalia/cookieconsent')}
        <a 
          class="text-white"
          role="button"
          href="#" 
          data-cc="show-preferencesModal">
          {'Cookie settings'|i18n('bootstrapitalia/cookieconsent')}
        </a>
      </p>
      <div class="acceptoverlay-buttons bg-dark">
        <button
          type="button"
          class="btn btn-primary"
          data-bs-accept-from="multimedia"
          onclick="loadVideo(`vid-{$video.id}`)">
          {'Accept for this video'|i18n('bootstrapitalia/cookieconsent')}
        </button>
        <button
          type="button"
          class="btn btn-outline-primary"
          data-bs-accept-from="multimedia"
          data-cc="accept-all"
          onclick="loadVideo(`vid-{$video.id}`)">
          {'Accept for all videos'|i18n('bootstrapitalia/cookieconsent')}
        </button>
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
{elseif $youtube_video}
<div class="acceptoverlayable" style="min-height: 350px">
  <div class="acceptoverlay acceptoverlay-primary fade show align-items-center">
    <div class="acceptoverlay-inner d-flex flex-column-reverse flex-sm-column">
      <div class="acceptoverlay-icon d-none d-sm-block mb-0">
        {display_icon('it-video', 'svg', 'icon icon-xl')}
      </div>
      <div class="acceptoverlay-buttons bg-dark mb-4 mt-2 mb-sm-0 mt-sm-4 flex-column align-items-center">
        <a
          class="btn btn-primary btn-xs font-sans-serif"
          target="_blank"
          rel="noopener noreferrer"
          href={$video.content}>
          {'Watch this content on %provider'|i18n('bootstrapitalia/cookieconsent',,hash('%provider', "Youtube"))} 
        </a>
      </div>
    </div>
  </div>
</div>
{else}
  {def $oembed = get_oembed_object($video.content)}
  <div class="video-wrapper">{$oembed.html}</div>
  {undef $oembed}
{/if}
{undef $youtube_video}