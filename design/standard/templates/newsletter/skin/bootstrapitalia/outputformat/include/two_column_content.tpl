<div class="mj-column-per-50 outlook-group-fix" style="font-size:13px;text-align:left;direction:ltr;display:inline-block;vertical-align:top;width:100%;">
    <table border="0" cellpadding="0" cellspacing="0" role="presentation" style="vertical-align:top;" width="100%">
        
        {if $content|has_image()}
        <tr>
            <td align="center" style="font-size:0px;padding:10px 25px;word-break:break-word;">
                <table align="center" border="0" cellpadding="0" cellspacing="0" role="presentation" style="border-collapse:collapse;border-spacing:0px;">
                    <tbody>
                        <tr>
                            <td style="width:250px;">

                                <img height="auto" src="{include name="main_image" uri='design:atoms/image_url.tpl' node=$content image_class=large}" style="border:0;display:block;outline:none;text-decoration:none;height:auto;width:100%;" width="250" />

                            </td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
        {/if}

        <tr>
            <td align="left" style="font-size:0px;padding:10px 25px;word-break:break-word;">
                <div style="font-family:'Titillium Web',Geneva,Tahoma,sans-serif;font-size:14pt;line-height:1;text-align:left;color:#000000;">
                    
                    {$content.name|wash()}

                </div>
            </td>
        </tr>

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