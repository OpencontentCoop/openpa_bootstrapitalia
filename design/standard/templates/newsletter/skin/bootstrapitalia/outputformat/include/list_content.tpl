<!--[if mso | IE]>
<table align="center" border="0" cellpadding="0" cellspacing="0" class="" style="width:600px;" width="600">
<tr>
<td style="line-height:0px;font-size:0px;mso-line-height-rule:exactly;">
<![endif]-->

<div style="background:#fff;background-color:#fff;Margin:0px auto;max-width:600px;">

    <table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="background:#fff;background-color:#fff;width:100%;">
        <tbody>
            <tr>
                <td style="border-bottom:1px solid #ccc;direction:ltr;font-size:0px;padding:20px 0;text-align:center;vertical-align:top;">
<!--[if mso | IE]>
<table role="presentation" border="0" cellpadding="0" cellspacing="0">
<tr>
<td class="" style="vertical-align:top;width:600px;">
<![endif]-->

                    <div class="mj-column-per-100 outlook-group-fix" style="font-size:13px;text-align:left;direction:ltr;display:inline-block;vertical-align:top;width:100%;">

                        <table border="0" cellpadding="0" cellspacing="0" role="presentation" style="vertical-align:top;" width="100%">

                            <tr>
                                <td align="left" style="font-size:0px;padding:0 25px;word-break:break-word;">

                                    <div style="font-family:'Titillium Web',Geneva,Tahoma,sans-serif;font-size:12pt;line-height:1;text-align:left;color:#000000;">
                                        <a href="{concat($site_url, '/', $content.object.main_node.url_alias)}">{$content.name|wash()} ></a>
                                    </div>

                                </td>
                            </tr>

                            {if $content|has_abstract()}   
                            <tr>
                                <td align="left" style="font-size:0px;padding:0 25px;word-break:break-word;">

                                    <div style="font-family:'Titillium Web',Geneva,Tahoma,sans-serif;font-size:10pt;line-height:auto;text-align:left;color:#000000;">
                                        {$content|abstract()}
                                    </div>

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