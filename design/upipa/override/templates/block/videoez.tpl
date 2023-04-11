{def $flash_node = $block.valid_nodes[0]
$siteurl = concat( "http://", ezini( 'SiteSettings', 'SiteURL' ) )
$attribute_file = $flash_node.data_map.file
$video = concat("content/download/", $attribute_file.contentobject_id, "/", $attribute_file.content.contentobject_attribute_id)|ezurl(no)
$flash_var = concat( "moviepath=", $video )}

{if $attribute_file}
    <div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
        <h3 class="openpa-widget-title">{node_view_gui content_node=$flash_node view=text_linked text=$block.name}</h3>
        <div class="openpa-widget-content">

            {* Embed URL, which URL to retrieve the embed code from. *}
            {set $flash_var=$flash_var|append( "&amp;embedurl=", concat( $siteurl, "/flash/embed/", $flash_node.object.id ) )}

            {* Embed Link *}
            {set $flash_var=$flash_var|append( "&amp;embedlink=", concat( $siteurl, $flash_node.url_alias|ezurl(no) ) )}


            <div class="content-media" id="flash-{$block.zone_id}-{$block.id}">

                <script>
                    <!--
                    var flash_id = "flash-{$block.zone_id}-{$block.id}";

                    var flashStart = '<object type="application/x-shockwave-flash" data={"flash/flash_player.swf"|ezdesign} width="100%" height="211">';
                    var flash = '<param name="movie" value={"flash/flash_player.swf"|ezdesign}  /> ';
                    flash = flash + '<param name="scale" value="exactfit" /> ';
                    flash = flash + '<param name="allowScriptAccess" value="sameDomain" />';
                    flash = flash + '<param name="allowFullScreen" value="true" />';
                    flash = flash + '<param name="flashvars" value="{$flash_var}" />';
                    flash = flash + '<param name="wmode" value="opaque" />';
                    flash = flash + '<p>No <a href="http://www.macromedia.com/go/getflashplayer">Flash player<\/a> avaliable!<\/p>';
                    var flashEnd = '<\/object>';

                    insertMedia2(flash_id, flashStart + flash + flashEnd);
                    //-->
                </script>
                <noscript>
                    <object type="application/x-shockwave-flash" data="{'flash/flash_player.swf'|ezdesign(no)}"
                            width="100%" height="211">
                        <param name="movie" value="{'flash/flash_player.swf'|ezdesign(no)}"/>
                        <param name="scale" value="exactfit"/>
                        <param name="allowScriptAccess" value="sameDomain"/>
                        <param name="allowFullScreen" value="true"/>
                        <param name="flashvars" value="{$flash_var}"/>
                        <param name="wmode" value="opaque"/>
                        <p>No <a href="http://www.macromedia.com/go/getflashplayer">Flash player</a> avaliable!</p>
                    </object>
                </noscript>

            </div>
            <div class="well video-description float-break">
                <h4 class="openpa-widget-title-lev2">{attribute_view_gui attribute=$flash_node.data_map.name}</h4>
                {if $flash_node.data_map.description.has_content}
                    <div class="attribute-intro">{attribute_view_gui attribute=$flash_node.data_map.description}</div>{/if}
                <p class="link">
                    <a class="arrows" title="Entra" href={$flash_node.parent.url_alias|ezurl()}><span
                                class="arrows-blue-r">Entra in {$flash_node.parent.name}</span></a>
                </p>
            </div>
        </div>
    </div>
{else}
    {editor_warning("L'oggetto inserito non &egrave; compatibile con la vista ({$block.view}) del blocco selezionato")}
{/if}
{undef}
