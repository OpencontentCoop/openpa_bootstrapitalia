{if $attribute.has_content}
	{def $groups = ocmultibinary_available_groups($attribute)}
	{if count($groups)|eq(0)}{set $groups = $groups|append('')}{/if}
	{def $groups_count = count($groups)}
	{def $file_list = array()}
  {if $in_accordion}
    {foreach $groups as $group}
      <ul class="link-list">
        {foreach ocmultibinary_list_by_group($attribute, $group) as $file}
          <li>
            <div class="cmp-icon-link mb-2">
              <a class="list-item icon-left d-inline-block font-sans-serif mb-0"
				 href="{concat( 'ocmultibinary/download/', $attribute.contentobject_id, '/', $attribute.id,'/', $attribute.version , '/', $file.filename ,'/file/', $file.original_filename|urlencode )|ezurl(no)}"
                aria-label=""
                title=""
                data-focus-mouse="false">{*
                *}<span class="list-item-title-icon-wrapper">{*
                *}{display_icon('it-clip', 'svg', 'icon icon-primary icon-sm me-1')}{*
                *}<span class="list-item">{*
                *}{if $file.display_name|ne('')}{$file.display_name|clean_filename()|wash( xhtml )}{else}{$file.original_filename|clean_filename()|wash( xhtml )}{/if}{*
                *}</span>{*
                *}</span>{*
                *}</a>
				<small class="d-block mt-2 mb-4" style="margin-left: 28px !important;">{if $file.display_text|ne('')}{$file.display_text|wash( xhtml )} <br>{/if}(File {$file.mime_type|explode('application/')|implode('')} {*<em>{$file.original_filename|wash()}</em>*} {$file.filesize|si( byte )})</small>
            </div>
          </li>
        {/foreach}
      </ul>
    {/foreach}
  {else}
	{if $groups_count|eq(1)}
		<div class="row mx-lg-n3">
			{foreach $groups as $group}
				{set $file_list = ocmultibinary_list_by_group($attribute, $group)}
				{if and($group|ne(''), $file_list|count()|gt(0))}
				<div class="col-12 px-lg-3">
					<h6 class="no_toc">{$group|wash()}</h6>
				</div>
				{/if}
				<div class="col-12">
					<div class="row row-cols-2 mx-0">
					{foreach $file_list as $file}
					  <div class="col font-sans-serif card card-teaser card-teaser-info rounded shadow-sm p-3 card-teaser-info-width mt-0 mb-3">
						{display_icon('it-clip', 'svg', 'icon')}
						<div class="card-body">
						  <h5 class="card-title">
						  <a class="stretched-link" href={concat( 'ocmultibinary/download/', $attribute.contentobject_id, '/', $attribute.id,'/', $attribute.version , '/', $file.filename ,'/file/', $file.original_filename|urlencode )|ezurl}>
							{if $file.display_name|ne('')}{$file.display_name|clean_filename()|wash( xhtml )}{else}{$file.original_filename|clean_filename()|wash( xhtml )}{/if}
						  </a>
						  {if $file.display_text|ne('')}
							<small class="d-block my-2">{$file.display_text|wash( xhtml )}</small>
						  {/if}
						  <small class="d-block" title="{$file.mime_type|wash()}"> (File {$file.mime_type|explode('application/')|implode('')|shorten(20)} {$file.filesize|si( byte )})</small>
						  </h5>
						</div>
					  </div>
					{/foreach}
				  </div>
				</div>
			{/foreach}
		</div>
	{else}
		{ezscript_require('jquery.quicksearch.min.js')}
		{run-once}
		<script>{literal}
			$(document).ready(function (){
				$('.multibinary-search').each(function (){
					var searchInput = $(this).find('input');
					var containerId = $(this).find('.link-list').attr('id');
					searchInput.quicksearch('#'+containerId+ ' li');
				});
			})
		{/literal}</script>
		{/run-once}
		<div class="cmp-accordion accordion my-4 font-sans-serif" role="tablist">
			{foreach $groups as $index => $group}
				{set $file_list = ocmultibinary_list_by_group($attribute, $group)}
				{if $file_list|count()|eq(0)}{skip}{/if}
				<div class="accordion-item">
				<h2 class="accordion-header" id="heading-{$attribute.id}-{$index}">
					<button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapse-{$attribute.id}-{$index}" aria-expanded="false" aria-controls="collapse-{$attribute.id}-{$index}">
						{if $group|eq('')}{'More...'|i18n('design/base')}{else}{$group|wash()}{/if}
					</button>
				</h2>
				<div id="collapse-{$attribute.id}-{$index}" class="accordion-collapse collapse" role="region" aria-labelledby="heading-{$attribute.id}-{$index}">
					<div class="accordion-body pb-2{if count($file_list)|gt(3)} multibinary-search{/if}">
							{if count($file_list)|gt(3)}
							<div class="form-group mb-4">
								<input type="text"
									   class="form-control form-control-sm"
									   placeholder="{'Search in'|i18n('bootstrapitalia')} {$group|wash()}"
									   aria-invalid="false"/>
								<label class="d-none">
									{'Search in'|i18n('bootstrapitalia')} {$group|wash()}
								</label>
								<button class="autocomplete-icon btn btn-link" style="width: auto;" aria-label="{'Search'|i18n('openpa/search')}">
									{display_icon('it-search', 'svg', 'icon icon-sm')}
								</button>
							</div>
							{/if}
							<ul class="link-list mb-0" id="list-{$attribute.id}-{$index}">
								{foreach $file_list as $file}
									<li>
										<div class="cmp-icon-link mb-2 pb-2">
                      {if $file.display_text|ne('')}
                        <small class="d-block my-2">{$file.display_text|wash( xhtml )}</small>
                      {/if}
											<a class="list-item icon-left d-inline-block font-sans-serif" href={concat( 'ocmultibinary/download/', $attribute.contentobject_id, '/', $attribute.id,'/', $attribute.version , '/', $file.filename ,'/file/', $file.original_filename|urlencode )|ezurl}>
												<span class="list-item-title-icon-wrapper">
													{display_icon('it-clip', 'svg', 'icon')}
													<span class="list-item">
														{if $file.display_name|ne('')}{$file.display_name|clean_filename()|wash( xhtml )}{else}{$file.original_filename|clean_filename()|wash( xhtml )}{/if}
														<em>
															<small title="{$file.mime_type|wash()}"> - File {$file.mime_type|explode('application/')|implode('')|shorten(20)} {$file.filesize|si( byte )}</small>
														</em>
													</span>
												</span>
											</a>
										</div>
									</li>
								{/foreach}
							</ul>
{*						</div>*}
					</div>
				</div>
			</div>
			{/foreach}
		</div>
	{/if}
  {/if}
	{undef $groups $groups_count}
{/if}
