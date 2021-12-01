<!--[if mso | IE]>
<table align="center" border="0" cellpadding="0" cellspacing="0" class="" style="width:600px;" width="600">
<tr>
<td style="line-height:0px;font-size:0px;mso-line-height-rule:exactly;">
<![endif]-->


<div style="background:#CCC;background-color:#CCC;Margin:0px auto;max-width:600px;">

    <table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="background:#CCC;background-color:#CCC;width:100%;">
        <tbody>
            <tr>
                <td style="direction:ltr;font-size:0px;padding:0;text-align:center;vertical-align:top;">
<!--[if mso | IE]>
<table role="presentation" border="0" cellpadding="0" cellspacing="0">
<tr>
<td class="" style="vertical-align:top;width:600px;">
<![endif]-->
                    <div class="mj-column-per-100 outlook-group-fix" style="font-size:13px;text-align:left;direction:ltr;display:inline-block;vertical-align:top;width:100%;">
                        <table border="0" cellpadding="0" cellspacing="0" role="presentation" style="vertical-align:top;" width="100%">
                            <tr>
                                <td align="left" style="font-size:0px;padding:10px 25px;word-break:break-word;">
                                    <div style="font-family:Arial,Helvetica,sans-serif;font-size:9pt;line-height:auto;text-align:left;color:#000000;">
                                        {'To unsubscribe from this newsletter please visit the following link'|i18n('cjw_newsletter/skin/default')}: 
                                        <a href="{concat($site_url,'/newsletter/unsubscribe/#_hash_unsubscribe_#')}">annulla sottoscrizione</a>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </div>
<!--[if mso | IE]>
</td>
</tr>
</table>
<![endif]-->
                </td>
            </tr>
        </tbody>
    </table>
</div>


<!--[if mso | IE]>
</td>
</tr>
</table>

<table align="center" border="0" cellpadding="0" cellspacing="0" class="" style="width:600px;" width="600">
<tr>
<td style="line-height:0px;font-size:0px;mso-line-height-rule:exactly;">
<![endif]-->


<div style="background:{$footer_bg_color};background-color:{$footer_bg_color};Margin:0px auto;max-width:600px;">

    <table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="background:{$footer_bg_color};background-color:{$footer_bg_color};width:100%;">
        <tbody>
            <tr>
                <td style="direction:ltr;font-size:0px;padding:20px 0;text-align:center;vertical-align:top;">
<!--[if mso | IE]>
<table role="presentation" border="0" cellpadding="0" cellspacing="0">
<tr>
<td class="" style="vertical-align:top;">
<![endif]-->

                    <div class="mj-column-per-100 outlook-group-fix" style="font-size:13px;text-align:left;direction:ltr;display:inline-block;vertical-align:top;width:100%;">
                        <table border="0" cellpadding="0" cellspacing="0" role="presentation" style="vertical-align:top;" width="100%">
                            {if and( is_set( $main_node.parent.data_map.footer_link ), $main_node.parent.data_map.footer_link.has_content )}      
                            <tr>
                                <td align="left" style="font-size:0px;padding:10px 25px;word-break:break-word;">
                                <div style="font-family:Arial,Helvetica,sans-serif;font-size:8pt;line-height:1;text-align:left;color:#FFFFFF;">
                                {foreach $main_node.parent.data_map.footer_link.content.relation_list as $relation}
                                  {def $related = fetch( content, object, hash( object_id, $relation.contentobject_id ) )}        
                                    <a style="color: #fff;" href="{concat($site_url, $related.main_node.url_alias|ezurl('no'))}">{$related.name|wash()}</a>
                                  {delimiter} - {/delimiter}
                                  {undef $related}
                                {/foreach}  
                                </div>
                                </td>
                            </tr>    
                            {/if}
                            <tr>
                                <td align="left" style="font-size:0px;padding:10px 25px;word-break:break-word;">
                                    <div style="font-family:Arial,Helvetica,sans-serif;font-size:10pt;line-height:1;text-align:left;color:#FFFFFF;">
                                        &copy; {currentdate()|datetime( 'custom', '%Y' )} {ezini('SiteSettings', 'SiteName')|wash()}
                                    </div>
                                </td>
                            </tr>                            
                        </table>

                    </div>

<!--[if mso | IE]>
</td>
</tr>
</table>
<![endif]-->
                </td>
            </tr>
        </tbody>
    </table>

</div>

<!--[if mso | IE]>
</td>
</tr>
</table>
<![endif]-->
