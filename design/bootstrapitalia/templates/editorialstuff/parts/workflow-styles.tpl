<style>
    {def $styles = array('#111', '#999', '#f0ad4e', '#5cb85c', '#d9534f')
         $index = 0}
    {foreach $states as $key => $state}
    .label-{$state.identifier} {ldelim}background-color: {$styles[$index]};{rdelim}
    {set $index = $index|inc()}
    {/foreach}
</style>