{if and(ezini_hasvariable('GeneralSettings', 'EnableSendy', 'sendy.ini'), ezini('GeneralSettings', 'EnableSendy', 'sendy.ini')|eq('enabled'))}
    {include uri='design:sendy/newsletter_subscribe.tpl'}
{else}
    <form action="{'newsletter/subscribe'|ezurl(no)}" method="post" class="form-newsletter">
        <label class="text-white font-weight-semibold active" for="input-newsletter" style="transition: none 0s ease 0s; width: auto;">Iscriviti per riceverla</label>
        <input type="email" class="form-control" id="input-newsletter" name="email" placeholder="mail@example.com" required>
        <button class="btn btn-primary btn-icon" type="submit">
            <svg class="icon icon-white">
                {display_icon('it-mail', 'svg', 'icon icon-white')}
            </svg>
            <span>Iscriviti</span>
        </button>
    </form>
{/if}