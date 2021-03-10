<style>
    {def $styles = array('#ddd', '#999', '#f0ad4e', '#5cb85c', '#d9534f', '#6b5b95', '#3e4444', '#feb236', '#ff7b25', '#6b5b95', '#86af49')
         $index = 0}
    {foreach $states as $key => $state}
    .label-{$state.identifier} {ldelim}background-color: {$styles[$index]};{rdelim}
    {set $index = $index|inc()}
    {/foreach}
</style>