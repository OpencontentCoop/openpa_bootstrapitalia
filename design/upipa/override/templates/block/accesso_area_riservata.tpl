{set_defaults( hash('show_title', true()) )}
{if $block.custom_attributes.parent_node_id}

{def $area = fetch( 'content', 'node', hash( 'node_id', $block.custom_attributes.parent_node_id ) )
     $current_user = fetch( 'user', 'current_user' )}

<div class="openpa-widget {$block.view} {if and(is_set($block.custom_attributes.color_style), $block.custom_attributes.color_style|ne(''))}color color-{$block.custom_attributes.color_style}{/if}">
    {if and( $show_title, $block.name|ne('') )}
        <h3 class="openpa-widget-title"><span>{$block.name|wash()}</span></h3>
    {/if}
    <div class="openpa-widget-content">
        {if and( $current_user.is_logged_in, fetch( 'content', 'access', hash( 'access', 'read', 'contentobject', $area )) )}
            <p><a class="btn btn-default" href={$area.url_alias|ezurl()} title="{$area.name|wash()}">Accedi all'area riservata</a></p>
        {else}
        
            <p>{$block.custom_attributes.testo}</p>
            
            <form method="post" action="{"/user/login/"|ezurl(no)}" name="loginform" class="form">
                <div class="form-group">
                    <label for="id-{$block.id}-login">{"Username"|i18n("design/ezwebin/user/login",'User name')}</label>
                    <input class="form-control" type="text" size="10" name="Login" id="id-{$block.id}-login" value="" tabindex="1" />
                </div>
                <div class="form-group">
                    <label for="id-{$block.id}-password">{"Password"|i18n("design/ezwebin/user/login")}</label>
                    <input class="form-control" type="password" size="10" name="Password" id="id-{$block.id}-password" value="" tabindex="2" />
                </div>
                
                <input class="defaultbutton" type="submit" name="LoginButton" value="{'Login'|i18n('design/ezwebin/user/login','Button')}" tabindex="3" />
                
                <input type="hidden" name="RedirectURI" value="{$area.url_alias}" />
            </form>
        
        {/if}
    </div>
</div>

{else}
    {editor_warning( "Area riservata non selezionata" )};
{/if}