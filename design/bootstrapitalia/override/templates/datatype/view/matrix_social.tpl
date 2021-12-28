{def $social_icons = hash(
    'Facebook', 'fa fa-facebook-square',
    'Instagram', 'fa fa-instagram',
    'Linkedin', 'fa fa-linkedin-square',
    'Twitter', 'fa fa-twitter-square',
    'Youtube', 'fa fa-youtube',
    'WhatsApp', 'fa fa-whatsapp',
    'Telegram', 'fa fa-telegram'
)}
{let matrix=$attribute.content}
    <ul class="list-inline">
    {foreach $matrix.rows.sequential as $row}
        {def $type = $row.columns[0]
        	 $value = $row.columns[1]}
        <li class="list-inline-item align-middle">
            <a href="{$value|wash()}">{if is_set($social_icons[$type])}<i class="{$social_icons[$type]} fa-2x" title="{$type|wash()}"></i>{else}{$type|wash()}{/if}</a>
        </li>
        {undef $type $value}
    {/foreach}
    </ul>
{/let}
{undef $social_icons}
