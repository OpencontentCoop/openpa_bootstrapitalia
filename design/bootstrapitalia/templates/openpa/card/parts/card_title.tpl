{if $view_variation|eq('alt')}
	<h5 class="card-title">
		<a class="text-decoration-none" href="{$openpa.content_link.full_link}">{$node.name|wash()}</a>
		{include uri='design:parts/card_title_suffix.tpl'}
		{if and($openpa.content_link.is_node_link|not(), $node.can_edit)}
			<a href="{$node.url_alias|ezurl(no)}">
				<span class="fa-stack">
				  <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
				  <i aria-hidden="true" class="fa fa-wrench fa-stack-1x fa-inverse"></i>
				</span>
			</a>
		{/if}
	</h5>
{else}
	<h5 class="card-title{if and($has_media|not(), $view_variation|eq('big')|not())} big-heading{/if}">
		{if and($view_variation|eq('big'), $show_icon, $has_media|not(), $node|has_attribute('time_interval'), $node.class_identifier|contains('event'))}
			{def $events = $node|attribute('time_interval').content.events}
			{def $is_recurrence = cond(count($events)|gt(1), true(), false())}
			{if count($events)|gt(0)}
				<div class="card-calendar d-flex flex-column justify-content-center" style="font-size: 0.67em;height: 80px;position: relative;float: right;right: -20px;top: -35px;">
					<span class="card-date">{if $is_recurrence}<small>{'from'|i18n('openpa/search')}</small> {/if}{recurrences_strtotime($events[0].start)|datetime( 'custom', '%j' )}</span>
					<span class="card-day">{recurrences_strtotime($events[0].start)|datetime( 'custom', '%F' )}</span>
				</div>
			{/if}
			{undef $events $is_recurrence}
		{/if}
		<a class="text-decoration-none" href="{$openpa.content_link.full_link}">{$node.name|wash()}</a>
		{include uri='design:parts/card_title_suffix.tpl'}
		{if and($openpa.content_link.is_node_link|not(), $node.can_edit)}
			<a href="{$node.url_alias|ezurl(no)}">
				<span class="fa-stack">
				  <i aria-hidden="true" class="fa fa-circle fa-stack-2x"></i>
				  <i aria-hidden="true" class="fa fa-wrench fa-stack-1x fa-inverse"></i>
				</span>
			</a>
		{/if}
	</h5>
{/if}