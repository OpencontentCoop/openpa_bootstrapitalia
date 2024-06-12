{if $attribute.content.tag_ids|count}
{*
    <div class="row align-items-center mt-10 mb-30">
        <div class="col-2">
*}
            <div class="d-flex flex-wrap gap-2 font-sans-serif mt-10 mb-30">
                {foreach $attribute.content.tags as $tag}
                    <div class="cmp-tag">
                        {if $show_link}
                            <a class="chip chip-simple chip-primary bg-tag text-decoration-none" href="{concat( '/tags/view/', $tag.url )|explode('tags/view/tags/view')|implode('tags/view')|ezurl(no)}">
                                <span class="chip-label text-nowrap">{$tag.keyword|wash}</span>
                            </a>
                        {else}
                            <div class="chip chip-simple chip-primary bg-tag text-decoration-none"><span class="chip-label">{$tag.keyword|wash}</span></div>
                        {/if}
                    </div>
                {/foreach}
            </div>
{*
        </div>
    {if $attribute.content.tags[0].remote_id|eq('projects_states_3')}
        <div class="col-10">
            <div class="progress-bar-wrapper">
                <div class="progress-bar-label"><span class="visually-hidden">{$attribute.content.keywords|implode(', ')} </span>10%</div>
                <div class="progress">
                    <div class="progress-bar" role="progressbar" style="width: 10%" aria-valuenow="10" aria-valuemin="0" aria-valuemax="100"></div>
                </div>
            </div>
        </div>
    {elseif $attribute.content.tags[0].remote_id|eq('projects_states_2')}
        <div class="col-10">
            <div class="progress progress-indeterminate">
                <span class="visually-hidden">{$attribute.content.keywords|implode(', ')}...</span>
                <div class="progress-bar" role="progressbar"></div>
            </div>
        </div>
    {elseif $attribute.content.tags[0].remote_id|eq('projects_states_1')}
            <div class="col-10">
                <div class="progress-bar-wrapper">
                    <div class="progress-bar-label"><span class="visually-hidden">{$attribute.content.keywords|implode(', ')} </span>100%</div>
                    <div class="progress">
                        <div class="progress-bar" role="progressbar" style="width: 100%" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                </div>
            </div>
    {/if}
    </div>
*}
{/if}