function init() {
    populate_tree("#panel");
}

function populate_tree(panel) {
    function populate(treedata, d3_element, parent) {
        for (i=0; i < treedata.length; ++i) {
            var node = treedata[i];

            if (parent != node.parent) {
                continue;
            }

            console.log("Populating " + node.filename + " " + node.path);

            var label = (
                parent == "" ? node.filename : node.path
            );

            if (node.type == "group") {
                var child_element = d3_element.append("details");

                child_element
                    .append("summary")
                    .text(label)
                ;

                populate(treedata, child_element, node.path);
            } else {
                var child_element = d3_element.append("div");

                child_element
                    .text(label)
                ;
            }

            child_element
                .on("click", function() {select_content(node, this);})
            ;
        }
    }

    function select_content(node, element) {
        console.log("Selecting " + node.filename + ":" + node.path);
    }

    function refresh_display(treedata, panel) {
        var d3_element = d3.select(panel);

        d3_element.html("");

        populate(treedata, d3_element, "");
    }

    ajaxFunction(
        "/api/tree/",

        function(ajax_result){
            refresh_display(ajax_result["nodes"], panel);
        },

        function(ajax_exception){
        },

        "GET"
    );
    
}
