{def $rating = $attribute.content}

{def $partial_1 = 0
     $partial_2 = 0
     $partial_3 = 0
     $partial_4 = 0
     $partial_5 = 0}

{foreach $rating.rating_data as $data}
    {switch match=$data.rating}
    {case match=1}
        {set $partial_1 = $partial_1|inc()}
    {/case}
    {case match=2}
        {set $partial_2 = $partial_2|inc()}
    {/case}
    {case match=3}
        {set $partial_3 = $partial_3|inc()}
    {/case}
    {case match=4}
        {set $partial_4 = $partial_4|inc()}
    {/case}
    {case match=5}
        {set $partial_5 = $partial_5|inc()}
    {/case}
    {case}{/case}
    {/switch}
{/foreach}

<div class="rating-list-wrapper my-4">
    <div class="rating-list">
        <div class="rating-list-aside rating-list-warning">
            <div class="rating-value font-weight-semibold">{$rating.rating|wash}</div>
            <div class="rating-total font-weight-semibold">{'out of'|i18n('bootstrapitalia')} 5</div>
        </div>
        <div class="rating-list-content">
            <div class="rating-list-row">
                <div class="rating-list-stars">
                    <div class="rating rating-read-only">
                        {display_icon('it-star-full', 'svg', 'icon icon-warning')}
                        {display_icon('it-star-full', 'svg', 'icon icon-warning')}
                        {display_icon('it-star-full', 'svg', 'icon icon-warning')}
                        {display_icon('it-star-full', 'svg', 'icon icon-warning')}
                        {display_icon('it-star-full', 'svg', 'icon icon-warning')}
                    </div>
                    <div class="rating rating-read-only">
                        {display_icon('it-star-full', 'svg', 'icon icon-warning')}
                        {display_icon('it-star-full', 'svg', 'icon icon-warning')}
                        {display_icon('it-star-full', 'svg', 'icon icon-warning')}
                        {display_icon('it-star-full', 'svg', 'icon icon-warning')}
                    </div>
                    <div class="rating rating-read-only">
                        {display_icon('it-star-full', 'svg', 'icon icon-warning')}
                        {display_icon('it-star-full', 'svg', 'icon icon-warning')}
                        {display_icon('it-star-full', 'svg', 'icon icon-warning')}
                    </div>
                    <div class="rating rating-read-only">
                        {display_icon('it-star-full', 'svg', 'icon icon-warning')}
                        {display_icon('it-star-full', 'svg', 'icon icon-warning')}
                    </div>
                    <div class="rating rating-read-only">
                        {display_icon('it-star-full', 'svg', 'icon icon-warning')}
                    </div>
                </div>
                <div class="rating-list-progress">
                    <div class="progress progress-color">
                        <div class="progress-bar bg-warning" role="progressbar" style="width: {mul(100,$partial_5)|div($rating.rating_count)|floor()}%" aria-valuenow="{mul(100,$partial_5)|div($rating.rating_count)|floor()}" aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                    <div class="progress progress-color">
                        <div class="progress-bar bg-warning" role="progressbar" style="width: {mul(100,$partial_4)|div($rating.rating_count)|floor()}%" aria-valuenow="{mul(100,$partial_4)|div($rating.rating_count)|floor()}" aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                    <div class="progress progress-color">
                        <div class="progress-bar bg-warning" role="progressbar" style="width: {mul(100,$partial_3)|div($rating.rating_count)|floor()}%" aria-valuenow="{mul(100,$partial_3)|div($rating.rating_count)|floor()}" aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                    <div class="progress progress-color">
                        <div class="progress-bar bg-warning" role="progressbar" style="width: {mul(100,$partial_2)|div($rating.rating_count)|floor()}%" aria-valuenow="{mul(100,$partial_2)|div($rating.rating_count)|floor()}" aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                    <div class="progress progress-color">
                        <div class="progress-bar bg-warning" role="progressbar" style="width: {mul(100,$partial_1)|div($rating.rating_count)|floor()}%" aria-valuenow="{mul(100,$partial_1)|div($rating.rating_count)|floor()}" aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>


<div class="hreview-aggregate clearfix">

    <ul id="ezsr_rating_{$attribute.id}" class="ezsr-star-rating">
        <li id="ezsr_rating_percent_{$attribute.id}" class="ezsr-current-rating" style="width:{$rating.rounded_average|div(5)|mul(100)}%;">{'Currently %current_rating out of 5 Stars.'|i18n('extension/ezstarrating/datatype', '', hash( '%current_rating', concat('<span>', $rating.rounded_average|wash, '</span>') ))}</li>
        {for 1 to 5 as $num}
            <li><a href="JavaScript:void(0);" id="ezsr_{$attribute.id}_{$attribute.version}_{$num}" title="{'Rate %rating stars out of 5'|i18n('extension/ezstarrating/datatype', '', hash( '%rating', $num ))}" class="ezsr-stars-{$num}" rel="nofollow" onfocus="this.blur();">{$num}</a></li>
        {/for}
    </ul>

    <p id="ezsr_just_rated_{$attribute.id}" class="ezsr-just-rated hide">{'Thank you for rating!'|i18n('extension/ezstarrating/datatype', 'When rating')}</p>
    <p id="ezsr_has_rated_{$attribute.id}" class="ezsr-has-rated hide">{'You have already rated this page, you can only rate it once!'|i18n('extension/ezstarrating/datatype', 'When rating')}</p>
    <p id="ezsr_changed_rating_{$attribute.id}" class="ezsr-changed-rating hide">{'Your rating has been changed, thanks for rating!'|i18n('extension/ezstarrating/datatype', 'When rating')}</p>
</div>

{run-once}
{ezcss_require( 'star_rating.css' )}
{if and( $attribute.data_int|not, has_access_to_limitation( 'ezjscore', 'call', hash( 'FunctionList', 'ezstarrating_rate' ) ))}
    {ezscript_require( array( 'ezstarrating_jquery.js' ) )}
{else}
    {if fetch( 'user', 'current_user' ).is_logged_in}
        <p id="ezsr_no_permission_{$attribute.id}" class="ezsr-no-permission">{"You don't have access to rate this page."|i18n( 'extension/ezstarrating/datatype' )}</p>
    {else}
        {if ezmodule( 'user/register' )}
            <p id="ezsr_no_permission_{$attribute.id}" class="ezsr-no-permission">{'%login_link_startLog in%login_link_end or %create_link_startcreate a user account%create_link_end to rate this page.'|i18n( 'extension/ezstarrating/datatype', , hash( '%login_link_start', concat( '<a href="', '/user/login'|ezurl('no'), '">' ), '%login_link_end', '</a>', '%create_link_start', concat( '<a href="', "/user/register"|ezurl('no'), '">' ), '%create_link_end', '</a>' ) )}</p>
        {else}
            <p id="ezsr_no_permission_{$attribute.id}" class="ezsr-no-permission">{'%login_link_startLog in%login_link_end to rate this page.'|i18n( 'extension/ezstarrating/datatype', , hash( '%login_link_start', concat( '<a href="', '/user/login'|ezurl('no'), '">' ), '%login_link_end', '</a>' ) )}</p>
        {/if}
    {/if}
{/if}
{/run-once}
{undef $rating $partial_1 $partial_2 $partial_3 $partial_4 $partial_5}