(function ($) {

    var Alpaca = $.alpaca;

    Alpaca.Fields.Tree = Alpaca.Fields.HiddenField.extend({
        getFieldType: function () {
            return "tree";
        },

        afterRenderControl: function(model, callback) {
            var self = this;
            this.base(model, function() {
                var container = self.getFieldEl();  
                
                var treeSearchInput = $('<input type="text" value="" class="form-control" placeholder="Cerca" />')
                treeSearchInput.appendTo(container); 

                var tree = $('<div></div>').jstree(self.options.tree).on("changed.jstree", function (e, data) {
                  self.setValue([data.node.text]);
                });
                tree.appendTo(container);

                var to = false;
                treeSearchInput.keyup(function () {
                    if(to) { clearTimeout(to); }
                    to = setTimeout(function () {
                        var v = treeSearchInput.val();
                        tree.jstree(true).search(v);
                    }, 250);
                });

                callback();

            });
        }
    });

    Alpaca.registerFieldClass("tree", Alpaca.Fields.Tree);

})(jQuery);
