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
                                <td align="left" style="font-size:0px;padding:10px 25px;word-break:break-word;">

                                    <div style="font-family:'Titillium Web',Geneva,Tahoma,sans-serif;font-size:18pt;line-height:1;text-align:left;color:#000000;">
                                        {$content.name|wash()}
                                    </div>

                                </td>
                            </tr>

                            {if $content|has_image()}
                              <tr>
                                  <td align="center" style="font-size:0px;padding:10px 25px;word-break:break-word;">

                                      <table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="border-collapse:collapse;border-spacing:0px;">
                                          <tbody>
                                              <tr>
                                                  <td style="width:550px;">

                                                      <img height="auto" src="{include name="main_image" uri='design:atoms/image_url.tpl' node=$content image_class=reference}" style="border:0;display:block;outline:none;text-decoration:none;height:auto;width:100%;" width="550" />

                                                  </td>
                                              </tr>
                                          </tbody>
                                      </table>

                                  </td>
                              </tr>                              
                            {/if}


                            {if $content|has_abstract()}   
                            <tr>
                                <td align="left" style="font-size:0px;padding:10px 25px;word-break:break-word;">

                                    <div style="font-family:'Titillium Web',Geneva,Tahoma,sans-serif;font-size:10pt;line-height:auto;text-align:left;color:#000000;">
                                        {$content|abstract()|openpa_shorten(500)}
                                    </div>

                                </td>
                            </tr>
                            {/if}

                            <tr>
                                <td align="right" style="font-size:0px;padding:10px 25px;word-break:break-word;">

                                    <div style="font-family:'Titillium Web',Geneva,Tahoma,sans-serif;font-size:10pt;line-height:1;text-align:right;text-transform:uppercase;color:#000000;">
                                        <a href="{concat($site_url, '/', $content.object.main_node.url_alias)}">Leggi tutto ></a>
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