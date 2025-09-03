<h1 class="my-4">Statistiche sito web</h1>

<h2 class="h4">Grafico</h2>
<iframe width="100%" height="301" src="https://api.webanalytics.italia.it/widgets/index.php?module=Widgetize&action=iframe&widget=1&moduleToWidgetize=VisitsSummary&actionToWidgetize=getEvolutionGraph&idSite={$site_id|wash()}&period=month&date=lastMonth&disableLink=1&forceView=1&viewDataTable=graphEvolution&evolution_month_last_n=6" scrolling="yes" frameborder="0" marginheight="0" marginwidth="0"></iframe>

<h2 class="h4">Dati del mese precedente</h2>
<iframe width="100%" height="522" src="https://api.webanalytics.italia.it/widgets/index.php?module=Widgetize&action=iframe&widget=1&moduleToWidgetize=VisitsSummary&actionToWidgetize=get&idSite={$site_id|wash()}&period=month&date=lastMonth&disableLink=1&forceView=1&viewDataTable=sparklines" scrolling="yes" frameborder="0" marginheight="0" marginwidth="0"></iframe>
