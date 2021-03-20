<div class="newsletter newsletter-subscribe">


    {def $newsletter_root_node_id = ezini( 'NewsletterSettings', 'RootFolderNodeId', 'cjw_newsletter.ini' )
         $available_output_formats = 2

         $newsletter_system_node_list = fetch( 'content', 'tree', hash( 'parent_node_id', $newsletter_root_node_id,
                                                                        'class_filter_type', 'include',
                                                                        'class_filter_array', array( 'cjw_newsletter_system' ),
                                                                        'sort_by', array( 'name', true() ),
                                                                        'limitation', hash( )
                                                                      )
                                              )
         $newsletter_list_count = fetch( 'content', 'tree_count',
                                                            hash('parent_node_id', $newsletter_root_node_id,
                                                                 'extended_attribute_filter',
                                                                      hash( 'id', 'CjwNewsletterListFilter',
                                                                            'params', hash( 'siteaccess', array( 'current_siteaccess' ) ) ),
                                                                 'class_filter_type', 'include',
                                                                 'class_filter_array', array('cjw_newsletter_list'),
                                                                 'limitation', hash() )
                                                       )}
    <h1>{'Newsletter subscribe'|i18n( 'cjw_newsletter/subscribe' )}</h1>


    {* check if nl system is available *}
    {if or( $newsletter_system_node_list|count()|eq(0), $newsletter_list_count|eq(0) )}
      <div class="block">
        <p>{'No newsletters available.'|i18n( 'cjw_newsletter/subscribe' )}</p>
      </div>

    {else}

      <form class="form-horizontal" role="form" name="subscribe" method="post" action={'/newsletter/subscribe/'|ezurl}>

        {* warnings *}
        {if and( is_set( $warning_array ), $warning_array|count|ne( 0 ) )}
        <div class="block">
            <div class="message-warning">
                <h2>{'Input did not validate'|i18n('cjw_newsletter/subscribe')}</h2>
                <ul class="list-unstyled">
                {foreach $warning_array as $message_array_item}
                    <li><span class="key">{$message_array_item.field_key|wash}: </span><span class="text">{$message_array_item.message|wash()}</span></li>
                {/foreach}
                </ul>
            </div>
        </div>
        {/if}

        <div class="abstract">
          <p>{'Here you can subscribe to one of our newsletters.'|i18n( 'cjw_newsletter/subscribe' )}</p>
          <p>{'Please fill in the boxes "first name" and "last name" and enter your e-mail address in the corresponding field. Then, select the newsletter you are interested in and the format you prefer.'|i18n( 'cjw_newsletter/subscribe' )}</p>
        </div>

          {foreach $newsletter_system_node_list as $system_node}

              {def $newsletter_list_node_list = fetch( 'content', 'tree',
                                                          hash('parent_node_id', $system_node.node_id,
                                                               'extended_attribute_filter',
                                                                    hash( 'id', 'CjwNewsletterListFilter',
                                                                          'params', hash( 'siteaccess', array( 'current_siteaccess' ) ) ),
                                                               'class_filter_type', 'include',
                                                               'class_filter_array', array('cjw_newsletter_list'),
                                                               'sort_by', $system_node.sort_array,
                                                               'limitation', hash() )
                                                     )
                   $newsletter_list_node_list_count = $newsletter_list_node_list|count}

                    {if $newsletter_list_node_list_count|ne(0)}
                        <h4>{$system_node.data_map.title.content|wash}</h4>
                        <table class="table">

                            {foreach $newsletter_list_node_list as $list_node sequence array( 'bglight', 'bgdark' ) as $style}
                                {def $list_id = $list_node.contentobject_id
                                     $list_selected_output_format_array = array(0)
                                     $td_counter = 0}

                                    {if is_set( $subscription_data_array.list_output_format_array[$list_id] )}
                                        {set $list_selected_output_format_array = $subscription_data_array.list_output_format_array[$list_id]}
                                    {/if}

                                <tr>
                                    {if $list_node.data_map.newsletter_list.content.output_format_array|count|ne(0)}

                                    {* check box subscribe to list *}
                                    <td valign="top" class="newsletter-list">
                                        <input type="hidden" name="Subscription_IdArray[]" value="{$list_id}" title="" />
                                        {if $newsletter_list_node_list_count|eq(1)}
                                            <div class="form-check form-check-inline">        
                                              <input class="form-check-input" id="list-{$list_id}" type="checkbox" name="Subscription_ListArray[]" value="{$list_id}" checked="checked" title="{$list_node.data_map.title.content|wash}" />
                                              <label class="form-check-label" for="list-{$list_id}">{$list_node.data_map.title.content|wash}</label>
                                            </div>
                                        {else}
                                            <div class="form-check form-check-inline">    
                                              <input class="form-check-input" id="list-{$list_id}" type="checkbox" name="Subscription_ListArray[]" value="{$list_id}"{if $subscription_data_array['list_array']|contains( $list_id )} checked="checked"{/if} title="{$list_node.data_map.title.content|wash}" />
                                              <label class="form-check-label" for="list-{$list_id}">{$list_node.data_map.title.content|wash}</label>
                                            </div>
                                        {/if}
                                    </td>
                                    {* outputformats *}

                                        {if $list_node.data_map.newsletter_list.content.output_format_array|count|gt(1)}

                                            {foreach $list_node.data_map.newsletter_list.content.output_format_array as $output_format_id => $output_format_name}
                                            <td class="newsletter-list">
                                              <div class="form-check form-check-inline"> 
                                                <input class="form-check-input" id="output-{$list_id}-{$output_format_id}" type="radio" name="Subscription_OutputFormatArray_{$list_id}[]" value="{$output_format_id}" {if $list_selected_output_format_array|contains( $output_format_id )} checked="checked"{/if} title="{$output_format_name|wash}" />
                                                <label class="form-check-label" for="output-{$list_id}-{$output_format_id}">{$output_format_name|wash}</label>
                                              </div>
                                            </td>
                                            {set $td_counter = $td_counter|inc}
                                            {/foreach}

                                        {else}

                                            {foreach $list_node.data_map.newsletter_list.content.output_format_array as $output_format_id => $output_format_name}
                                            <td class="newsletter-list">&nbsp;<input type="hidden" name="Subscription_OutputFormatArray_{$list_id|wash}[]" value="{$output_format_id|wash}" title="{$output_format_name|wash}" /></td>
                                            {set $td_counter = $td_counter|inc}
                                            {/foreach}

                                        {/if}

                                    {else}
                                    {* do nothing *}
                                    {/if}

                                    {* create missing  <td> *}
                                    {while $td_counter|lt( $available_output_formats )}
                                    <td>&nbsp;{*$td_counter} < {$available_output_formats*}</td>
                                    {set $td_counter = $td_counter|inc}
                                    {/while}

                                </tr>
                                {undef $list_id $list_selected_output_format_array $td_counter $newsletter_list_node_list_count}
                            {/foreach}
                        </table>
                    {/if}

                    {undef $newsletter_list_node_list}
                {/foreach}

            {* salutation *}
            <div class="form-group row mb-3">
              <label class="col-sm-2 control-label">{"Salutation"|i18n( 'cjw_newsletter/subscribe' )}:</label>
              <div class="col-sm-10">
                {foreach $available_salutation_array as $salutation_id => $salutation_name}
                  <div class="form-check form-check-inline">
                    <input class="form-check-input" id="salutation-{$salutation_id|wash}" type="radio" name="Subscription_Salutation" value="{$salutation_id|wash}"{if and( is_set( $subscription_data_array['salutation'] ), $subscription_data_array['salutation']|eq( $salutation_id ) )} checked="checked"{/if} title="{$salutation_name|wash}" />
                    <label class="form-check-label" for="salutation-{$salutation_id|wash}">{$salutation_name|wash}</label>
                  </div>
                {/foreach}
              </div>
            </div>

            {* First name. *}
            <div class="form-group row mb-3">
                <label class="col-sm-2 control-label" for="Subscription_FirstName">{"First name"|i18n( 'cjw_newsletter/subscribe' )}:</label>
                <div class="col-sm-10">
                <input class="form-control" id="Subscription_FirstName" autocomplete="given-name" type="text" name="Subscription_FirstName" value="{cond( and( is_set( $user), $subscription_data_array['first_name']|eq('') ), $user.contentobject.data_map.first_name.content|wash , $subscription_data_array['first_name'] )|wash}" title="{'First name of the subscriber.'|i18n( 'cjw_newsletter/subscribe' )}"
                       {*cond( is_set( $user ), 'disabled="disabled"', '')*} />
                </div>
            </div>

            {* Last name. *}
            <div class="form-group row mb-3">
                <label class="col-sm-2 control-label" for="Subscription_LastName">{"Last name"|i18n( 'cjw_newsletter/subscribe' )}:</label>
                <div class="col-sm-10">
                <input class="form-control" id="Subscription_LastName" autocomplete="family-name" type="text" name="Subscription_LastName" value="{cond( and( is_set( $user ), $subscription_data_array['last_name']|eq('') ), $user.contentobject.data_map.last_name.content|wash , $subscription_data_array['last_name'] )|wash}" title="{'Last name of the subscriber.'|i18n( 'cjw_newsletter/subscribe' )}"
                       {*cond( is_set( $user ), 'disabled="disabled"', '')*} />
                </div>
            </div>

            {* Email. *}
            <div class="form-group row mb-3">
                <label class="col-sm-2 control-label" for="Subscription_Email">{"E-mail"|i18n( 'cjw_newsletter/subscribe' )}:</label>
                <div class="col-sm-10">
                  <input required="required" class="form-control" id="Subscription_Email" autocomplete="email" type="text" name="Subscription_Email" value="{cond( and( is_set( $user ), $subscription_data_array['email']|eq('') ), $user.email|wash(), $subscription_data_array['email']|wash )}" title="{'Email of the subscriber.'|i18n( 'cjw_newsletter/subscribe' )}" />
                </div>
            </div>

          <div class="checkbox">
              <div class="form-check form-check-inline">              
                <input required="required" class="form-check-input"  type="checkbox" id="Privacy" />
                <label class="form-check-label" for="Privacy">Dichiaro di aver preso visione dell'<a href="#" data-toggle="modal" data-target="#informativa">informativa sul trattamento dei dati personali</a>.</label>
              </div>
          </div>

            <div class="my-4">
                {if $recaptcha_public_key}
                <div class="g-recaptcha" data-sitekey="{$recaptcha_public_key}"></div>
                <script type="text/javascript" src="https://www.google.com/recaptcha/api.js?hl={fetch( 'content', 'locale' ).country_code|downcase}"></script>
                {/if}
                <input type="hidden" name="BackUrlInput" value="{cond( ezhttp_hasvariable('BackUrlInput'), ezhttp('BackUrlInput')|wash(), 'newsletter/subscribe'|ezurl('no'))}" />
                <input id="SubscribeButton" class="btn btn-primary btn-lg pull-right" disabled="disabled" type="submit" name="SubscribeButton" value="{'Subscribe'|i18n( 'cjw_newsletter/subscribe' )}" title="{'Add to subscription.'|i18n( 'cjw_newsletter/subscribe' )}" />
                {*<a href={$node_url|ezurl}><input class="btn btn-danger pull-left" type="submit" name="CancelButton" value="{'Cancel'|i18n( 'cjw_newsletter/subscribe' )}" /></a>*}
            </div>

            <div class="block footer">
                <p>
                  <strong>{'Further Options'|i18n( 'cjw_newsletter/subscribe' )}:</strong>
                  {def $link = concat('<a href=', '/newsletter/subscribe_infomail'|ezurl() ,'>' ) }
                  {"You want to %unsubscribelink or %changesubscribelink your profile?"|i18n('cjw_newsletter/subscribe',, hash( '%unsubscribelink' , concat( $link ,'unsubscribe'|i18n('cjw_newsletter/subscribe'), '</a>'),'%changesubscribelink' , concat( $link,'change'|i18n('cjw_newsletter/subscribe'), '</a>')))}
                  {undef $link}
                </p>
            </div>
        </form>
    {/if}


</div>
<div id="informativa" class="modal fade">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-body">
                <div class="clearfix">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true" aria-label="{'Close'|i18n('bootstrapitalia')}" title="{'Close'|i18n('bootstrapitalia')}">&times;</button>
                </div>
                <div class="clearfix pb-5">
                    {include uri='design:newsletter/informativa.tpl'}
                    <a class="btn btn-info pull-right" href="#" data-dismiss="modal" aria-hidden="true" aria-label="{'Close'|i18n('bootstrapitalia')}" title="{'Close'|i18n('bootstrapitalia')}">{'Close'|i18n('bootstrapitalia')}</a>
                </div>
            </div>
        </div>
    </div>
</div>

<script>{literal}
$(document).ready(function(){
    $('#Privacy').bind('change', function(e){
        if( $(e.currentTarget).is(':checked') ){
            $('#SubscribeButton').removeAttr( 'disabled' );
        }else{
            $('#SubscribeButton').attr( 'disabled', 'disabled' );
        }
    });
});
{/literal}</script>

