<div class="card card-teaser shadow p-4 rounded border m-3 {if and(is_set( $align ), $align )}{if $align|eq('center')} mx-auto d-block{else} col-12 col-sm-12 col-md-6 col-lg-6 col-xl-6 float-none float-sm-none float-md-{$align} float-lg-{$align} float-xl-{$align}{/if}{/if}">
    <div class="card-body">
	    {if is_set($title)}
		  <h5 class="card-title mb-1">{$title}</h5>
		{/if}
	    <div class="card-text">
	        {$content}
	    </div>
	</div>
</div>