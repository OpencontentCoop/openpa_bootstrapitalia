{if $main_node.data_map.description.has_content}
<!--[if mso | IE]>     
<table align="center" border="0" cellpadding="0" cellspacing="0" class="" style="width:600px;" width="600">
<tr>
<td style="line-height:0px;font-size:0px;mso-line-height-rule:exactly;">
<![endif]-->


<div style="background:#fff;background-color:#fff;Margin:0px auto;max-width:600px;">

    <table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="background:#fff;background-color:#fff;width:100%;">
        <tbody>
            <tr>
                <td style="border-bottom:1px solid #ccc;direction:ltr;font-size:0px;padding:0;text-align:center;vertical-align:top;">
<!--[if mso | IE]>
<table role="presentation" border="0" cellpadding="0" cellspacing="0">
<tr>
<td class="" style="vertical-align:top;width:600px;">
<![endif]-->

                    <div class="mj-column-per-100 outlook-group-fix" style="font-size:13px;text-align:left;direction:ltr;display:inline-block;vertical-align:top;width:100%;">
                        <table border="0" cellpadding="0" cellspacing="0" role="presentation" style="vertical-align:top;" width="100%">
                            <tr>
                                <td align="left" style="font-size:0px;padding:10px 25px;word-break:break-word;">
                                    <div style="font-family:Arial,Helvetica,sans-serif;font-size:12pt;line-height:1;text-align:left;color:#000000;">
                                        {attribute_view_gui attribute=$main_node.data_map.description}
                                    </div>
                                </td>
                            </tr>
                            {if and( is_set( $main_node.parent.data_map.banner ), $main_node.parent.data_map.banner.has_content )}
                            <tr>
                                <td>
                                    <img height="auto" src="{$main_node.parent.data_map.banner.content['original'].url|ezroot(no, full)|explode('http://')|implode('https://')}" style="border:0;display:block;outline:none;text-decoration:none;height:auto;width:100%;" width="100%" />
                                </td>
                            </tr>
                            {/if}
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
{/if}
