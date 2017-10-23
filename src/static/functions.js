function init() {
    populate_tree("#panel");
}

function populate_tree(panel) {
    function populate(treedata, d3_element, filename, parent, depth, item_count) {
        for (var i=0; i < item_count; ++i) {
            var node = treedata[i];

            if (filename != node.filename && filename != null) {
                continue;
            }
            else if (parent != node.parent) {
                continue;
            }

            var label = (
                parent == "" ? node.filename : node.path
            );

            if (node.type == "group") {
                var child_element = d3_element.append("details");

                child_element
                    .append("summary")
                    .text(label)
                    .on("click", function() {select_group(node, this);})
                ;

                populate(treedata, child_element, node.filename, node.path, depth + 1, item_count);
            } else {
                var child_element = d3_element.append("div");

                child_element
                    .text(label)
                    .on("click", function() {select_content(node, this);})
                ;
            }
        }
    }

    function select_group(node, element) {
        console.log("Selecting group" + node.filename + ":" + node.path);
    }

    function select_content(node, element) {
        console.log("Selecting " + node.filename + ":" + node.path);
    }

    ajaxFunction(
        "/api/tree/",

        function(ajax_result){
            var d3_element = d3.select(panel);
            var treedata = ajax_result["nodes"];
            d3_element.html("");
            populate(treedata, d3_element, null, "", 0, treedata.length);
        },

        function(ajax_exception){
        },

        "GET"
    );
    
}
