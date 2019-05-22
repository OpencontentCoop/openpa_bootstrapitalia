{*
    @var OCClassExtraParametersHandlerInterface $handler
    @var eZContentClass $class
*}

{if $handler.enabled}
<div class="row icon-select-preview ">
    <div class="col-sm-8">
        <select class="icon-select form-control"
                name="extra_handler_{$handler.identifier}[class][{$class.identifier}][icon]">
            <option></option>
            {foreach $handler.icon_list as $icon}
                <option value="{$icon.value}" {if $handler.icon|eq( $icon.value )}selected="selected"{/if}>
                    {$icon.name|wash( xhtml )}
                </option>
            {/foreach}
        </select>
    </div>
    <div class="col-sm-1 text-center">
        <svg class="icon"></svg>
    </div>
</div>
<script>{literal}
    $(document).ready(function () {
        var container = $('.icon-select-preview');
        var select = container.find('.icon-select');
        var preview = container.find('svg.icon');
        function displayIconSelect() {
            if (select.val() !== '')
                preview.html('<use xlink:href={/literal}"{'images/svg/sprite.svg'|ezdesign(no)}{literal}#'+select.val()+'"></use>')
            else
                preview.html('');
        }
        select.on('change', displayIconSelect);
        displayIconSelect();
    });
{/literal}</script>
{/if}