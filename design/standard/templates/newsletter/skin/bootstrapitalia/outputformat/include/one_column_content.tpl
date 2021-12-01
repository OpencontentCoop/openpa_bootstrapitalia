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

                                    <div style="font-family:Arial,Helvetica,sans-serif;font-size:18pt;line-height:1;text-align:left;color:#000000;">

                                        {if and($content|has_attribute('image')|not(), $content|has_attribute('time_interval'))}
                                            {def $events = $content|attribute('time_interval').content.events}
                                            {if count($events)|gt(0)}
                                                <strong>{recurrences_strtotime($events[0].start)|datetime( 'custom', '%j' )} {recurrences_strtotime($events[0].start)|datetime( 'custom', '%F' )}</strong>
                                            {/if}
                                            {undef $events}
                                        {/if}

                                        {$content.name|wash()}
                                    </div>

                                </td>
                            </tr>

                            {if $content|has_attribute('image')}
                              <tr>
                                  <td align="center" style="font-size:0px;padding:10px 25px;word-break:break-word;">

                                      <table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="border-collapse:collapse;border-spacing:0px;">
                                          <tbody>
                                              <tr>
                                                  <td style="width:550px;">

                                                      <div style="position:relative">
                                                          <img height="auto"
                                                               src="{include name="main_image" uri='design:newsletter/skin/bootstrapitalia/outputformat/include/image_url.tpl' node=$content image_class=reference}"
                                                               style="border:0;display:block;outline:none;text-decoration:none;height:auto;width:100%;"
                                                               width="550"/>

                                                          {if $content|has_attribute('time_interval')}
                                                              {def $events = $content|attribute('time_interval').content.events}
                                                              {def $is_recurrence = cond(count($events)|gt(1), true(), false())}
                                                              {if count($events)|gt(0)}
                                                                  <div style="font-family:Arial,Helvetica,sans-serif;height: 80%;max-height: 80px;width: 80px;border-radius: 4px;background-color: #fff;position: absolute;left: 10px;top: 10px;color: #455a64;text-align: center;font-weight: 600;line-height: 1.3;text-transform: capitalize;justify-content: center !important;flex-direction: column !important;display: flex !important;font-size: 14px;">
                                                                      <span style="font-size: 1.667em;font-weight: 700;display: block;">
                                                                          {if $is_recurrence}<small>dal </small>{/if}{recurrences_strtotime($events[0].start)|datetime( 'custom', '%j' )}</span>
                                                                      <span>{recurrences_strtotime($events[0].start)|datetime( 'custom', '%F' )}</span>
                                                                  </div>
                                                              {/if}
                                                              {undef $events $is_recurrence}
                                                          {/if}
                                                      </div>

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

                                    <div style="font-family:Arial,Helvetica,sans-serif;font-size:10pt;line-height:auto;text-align:left;color:#000000;">
                                        {$content|abstract()|openpa_shorten(500)}
                                    </div>

                                </td>
                            </tr>
                            {/if}

                            <tr>
                                <td align="right" style="font-size:0px;padding:10px 25px;word-break:break-word;">

                                    <div style="font-family:Arial,Helvetica,sans-serif;font-size:10pt;line-height:1;text-align:right;text-transform:uppercase;color:#000000;">
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
