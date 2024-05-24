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
                if (self.isDisplayOnly()){
                    var items = self.options.tree.core.data || [];
                    var texts = [];
                    var collectSelected = function (item) {
                        var selected = item.state.selected || false;
                        if (selected) {
                            texts.push(item.text)
                        }
                        if (item.children) {
                            $.each(item.children, function(){
                                collectSelected(this)
                            })
                        }
                    }
                    $.each(items, function(){
                        collectSelected(this)
                    })
                    container.append(texts.join(', '));
                } else {
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
                }

                callback();

            });
        }
    });

    Alpaca.registerFieldClass("tree", Alpaca.Fields.Tree);

})(jQuery);
