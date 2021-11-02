{if and($node|has_attribute('is_online'), $node|attribute('is_online').data_int|eq(1))}<span class="badge badge-default text-success border border-success">online</span>{/if}
