{def $base_url = "https://api.webanalytics.italia.it/widgets/index.php?module=Widgetize&action=iframe&widget=1&moduleToWidgetize="}

<div class="container" id="main-container">
  <div class="row justify-content-center">
    <div class="col-12 col-lg-10">
      <div class="cmp-breadcrumbs" role="navigation">
        <nav class="breadcrumb-container" aria-label="breadcrumb">
          <ol class="breadcrumb p-0" data-element="breadcrumb">
            <li class="breadcrumb-item"><a href="{'/'|ezurl(no)}">Home</a><span class="separator">/</span></li>
            <li class="breadcrumb-item active" aria-current="page">{'Website Stats'|i18n('bootstrapitalia')}</li>
          </ol>
        </nav>
      </div>
    </div>
  </div>
</div>
<div class="container mb-5">
  <div class="row justify-content-center">
    <div class="col-12 col-lg-10">
      <div class="cmp-hero">
        <section class="it-hero-wrapper bg-white d-block">
          <div class="it-hero-text-wrapper pt-0 ps-0 pb-4 ">
            <h1 class="text-black hero-title" data-element="page-name">{'Website Stats'|i18n('bootstrapitalia')}</h1>
          </div>
        </section>
      </div>
    </div>
  </div>
</div>

<h2 class="h4">{'Stats recent'|i18n('bootstrapitalia')}</h2>
<iframe
  title={'Stats recent'|i18n('bootstrapitalia')}
  width="100%"
  height="301"
  src="{$base_url}VisitsSummary&actionToWidgetize=getEvolutionGraph&idSite={$site_id|wash()}&period=month&date=lastMonth&disableLink=1&forceView=1&viewDataTable=graphEvolution&evolution_month_last_n=6"
  scrolling="yes"
  frameborder="0"
  marginheight="0"
  marginwidth="0"></iframe>

<h2 class="h4">{'Stats last month'|i18n('bootstrapitalia')}</h2>
<iframe
  title={'Stats last month'|i18n('bootstrapitalia')}
  width="100%"
  height="522"
  src="{$base_url}VisitsSummary&actionToWidgetize=get&idSite={$site_id|wash()}&period=month&date=lastMonth&disableLink=1&forceView=1&viewDataTable=sparklines"
  scrolling="yes"
  frameborder="0"
  marginheight="0"
  marginwidth="0"></iframe>

<h2 class="h4">{'Stats pages'|i18n('bootstrapitalia')}</h2>
<iframe
  title={'Stats pages'|i18n('bootstrapitalia')}
  width="100%"
  height="448"
  src="{$base_url}Actions&actionToWidgetize=getPageUrls&idSite={$site_id|wash()}&period=month&date=lastMonth&disableLink=1&filter_limit=5&flat=1"
  scrolling="yes"
  frameborder="0"
  marginheight="0"
  marginwidth="0"></iframe>

<h2 class="h4">{'Stats device'|i18n('bootstrapitalia')}</h2>
<iframe
  title={'Stats device'|i18n('bootstrapitalia')}
  width="100%"
  height="606"
  src="{$base_url}DevicesDetection&actionToWidgetize=getType&idSite={$site_id|wash()}&period=month&date=lastMonth&disableLink=1"
  scrolling="yes"
  frameborder="0"
  marginheight="0"
  marginwidth="0"></iframe>

<h2 class="h4">{'Stats channel'|i18n('bootstrapitalia')}</h2>
<iframe
  title={'Stats channel'|i18n('bootstrapitalia')}
  width="100%"
  height="389"
  src="{$base_url}Referrers&actionToWidgetize=getReferrerType&idSite={$site_id|wash()}&period=month&date=lastMonth&disableLink=1&filter_limit=5"
  scrolling="yes"
  frameborder="0"
  marginheight="0"
  marginwidth="0"></iframe>

{undef $base_url}