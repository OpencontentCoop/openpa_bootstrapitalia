{def $openpa = object_handler($node)}
<div class="card-wrapper card-space">
    <div class="card card-bg">
        <div class="card-body">
            <h5 class="card-title big-heading">{$node.name|wash()}</h5>
            {$node|abstract()}
            <a class="read-more" href="{$openpa.content_link.full_link}">
                <span class="text">Leggi di più</span>
                <svg class="icon">
                    <use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-arrow-right"></use>
                </svg>
            </a>
        </div>
    </div>
</div>