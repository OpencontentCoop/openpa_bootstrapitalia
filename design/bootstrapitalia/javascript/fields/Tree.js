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
                var treeSearchInput = $('<input type="text" value="" class="form-control" placeholder="'+self.options.tree.i18n.search+'" />')
                treeSearchInput.appendTo(container); 

                var tree = $('<div></div>').jstree(self.options.tree).on("changed.jstree", function (e, data) {
                    var i, j, r = [];
                    for(i = 0, j = data.selected.length; i < j; i++) {
                        r.push(data.instance.get_node(data.selected[i])[self.options.tree.property_value]);
                    }
                    self.setValue(r);
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
