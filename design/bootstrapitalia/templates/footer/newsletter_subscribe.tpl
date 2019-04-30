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