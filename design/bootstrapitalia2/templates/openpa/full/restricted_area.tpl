{ezpagedata_set( 'has_container', true() )}
{set-block scope=root variable=cache_ttl}0{/set-block}
{def $can_access = cond(fetch( 'user', 'current_user').is_logged_in, true(), false() )}

<section class="container">
    <div class="row">
        <div class="col py-lg-2">


            {if $can_access}
                <h1>{$node.name|wash()}</h1>
                {if $node|has_attribute('short_title')}
                    <h4 class="py-2">{$node|attribute('short_title').content|wash()}</h4>
                {/if}

                {if $node|has_attribute('short_description')}
                    <div class="lead">
                        {attribute_view_gui attribute=$node|attribute('short_description')}
                    </div>
                {/if}

            {else}


            <div class="row">
                <div class="col-md-8 offset-md-2 col-lg-4 offset-lg-4">
                    <h1>{$node.name|wash()}</h1>
                    {if $node|has_attribute('access_info')}
                    <div class="mb-3">
                        {attribute_view_gui attribute=$node|attribute('access_info')}
                    </div>
                    {/if}
                    <form style="max-width: 400px;margin: 10px auto 20px;"
                          class="validate-form border px-4 pt-5 pb-4 rounded bg-white text-center" method="post" action='{"/user/login/"|ezurl(no)}' name="loginform">
                        <div class='form-group'>
                            <div class='controls with-icon-over-input'>
                                <input type="text" autofocus="" autocomplete="off" name="Login"
                                       placeholder="{"Username"|i18n("design/ocbootstrap/user/login",'User name')}" class="form-control"
                                       data-rule-required="true" value="">
                                <i class='icon-user text-muted'></i>
                            </div>
                        </div>
                        <div class='form-group'>
                            <div class='controls with-icon-over-input'>
                                <input type="password" autocomplete="off" name="Password"
                                       placeholder="{"Password"|i18n("design/ocbootstrap/user/login")}" class="form-control"
                                       data-rule-required="true">
                                <i class='icon-lock text-muted'></i>
                            </div>
                        </div>
                        <button class='btn btn-lg btn-primary center-block'
                                name="LoginButton">
                                {'Login'|i18n('design/ocbootstrap/user/login','Button')}
                        </button>
                        <input type="hidden" name="RedirectURI" value="{concat($node.url_alias, '/(i)/', currentdate())|wash()}" />

                        <div class='text-center mt-3'>

                            <a class="text-decoration-none" href={if ezmodule( 'userpaex' )}{'/userpaex/forgotpassword'|ezurl}{else}{'/user/forgotpassword'|ezurl}{/if}>{'Forgot your password?'|i18n( 'design/ocbootstrap/user/login' )}</a>
                        </div>

                    </form>

                </div>
            </div>

            {ezscript_require(array("password-score/password.js"))}
            {literal}
                <script type="text/javascript">
                  $(document).ready(function() {
                    $('[name="Password"]').password({
                      strengthMeter:false,
                      message: "{/literal}{'Show/hide password'|i18n('ocbootstrap')}{literal}",
                    });
                  });
                </script>
            {/literal}

            {/if}
        </div>
    </div>
</section>

{if $can_access}
    {def $children_count = $node.children_count}
    <div class="section section-muted section-inset-shadow p-4 mt-4">
    {if $children_count}

        {def $page_limit = 10
             $sort = cond($node.sort_array[0][0]|eq('published'), array('attribute', $node.sort_array[0][1], 'restricted_document/publication_start_time'), $node.sort_array)
             $children = fetch( openpa, list, hash( 'parent_node_id', $node.node_id,
                                                    'offset', $view_parameters.offset,
                                                    'sort_by', $sort,
                                                    'limit', $page_limit ) )}
        <div class="py-5">
            <div class="container">
                <div class="row">
                    <div class="col">

                        <div class="calendar-vertical font-sans-serif">
                        {foreach $children as $child}
                            {def $openpa_child = object_handler($child)}
                            <div class="calendar-date">
                                <div class="calendar-date-day">
                                    <small class="calendar-date-day__year">{$child.object.published|datetime( 'custom', '%Y' )}</small>
                                    <span class="title-xxlarge-regular d-flex justify-content-center">{$child.object.published|datetime( 'custom', '%d' )}</span>
                                    <small class="calendar-date-day__month text-lowercase">{$child.object.published|datetime( 'custom', '%M' )}</small>
                                </div>
                                <div class="calendar-date-description rounded bg-white">
                                    <div class="calendar-date-description-content">
                                        <h3 class="title-medium-2 mb-0">
                                            <a class="stretched-link" href="{$openpa_child.content_link.full_link}">{$child.name|wash()}</a>
                                        </h3>
                                        <em>{$child|abstract()|oc_shorten(250)}</em>
                                    </div>
                                </div>
                            </div>
                            {undef $openpa_child}
                        {/foreach}
                        </div>


                        {include name=navigator
                               uri='design:navigator/google.tpl'
                               page_uri=$node.url_alias
                               item_count=$children_count
                               view_parameters=$view_parameters
                               item_limit=$page_limit}

                    </div>
                </div>
            </div>
        </div>

        {undef $children $page_limit}
    </div>
    {/if}
{/if}
