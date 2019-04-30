<div class="card card-teaser shadow p-4 rounded border m-3 w-50{if and(is_set( $align ), $align )}{if $align|eq('center')} mx-auto d-block{else} float-{$align}{/if}{/if}">
    <div class="card-body">
	    {if is_set($title)}
		  <h5 class="card-title mb-1">{$title}</h5>
		{/if}
	    <div class="card-text">
	        {$content}
	    </div>
	</div>
</div>