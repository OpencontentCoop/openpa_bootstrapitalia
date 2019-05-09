<form class="section-search-form" action="ricerca.html" method="post">
    <div class="form-group">
        <label class="sr-only active" for="search-text" style="transition: none 0s ease 0s;">
            Cerca in {$current_node.name|wash()}
        </label>
        <input type="text"
               class="form-control"
               id="search-text"
               name="cercatxt"
               placeholder="Cerca in {$current_node.name|wash()}"
               aria-invalid="false"/>
        <a class="input-icon-suffix" data-toggle="modal" data-target="#searchModal">
            <svg class="icon">
                <use xlink:href="{'images/svg/sprite.svg'|ezdesign(no)}#it-search"></use>
            </svg>
        </a>
    </div>
</form>