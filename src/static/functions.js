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
            else if (node.name == "_i_table") { // Skip Pandas _i_table column stores
                continue;
            }

            var label = (
                parent == "" ? node.filename : node.path
            );

            
            if (node.type == "group") {
                var child_element = d3_element.append("details");
                var node_data = node;

                child_element
                    .append("summary")
                    .text(label)
                    .on("click", function() {select_group(node_data, this);})
                ;

                populate(treedata, child_element, node.filename, node.path, depth + 1, item_count);
            } else {
                var child_element = d3_element.append("div");
                var node_data = node;

                child_element
                    .text(label)
                    .on("click", function() {select_content(node_data, this, 0, 40);})
                ;
            }
        }
    }

    function select_group(node, element) {
        console.log("Selecting group" + node.filename + ":" + node.path);
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

function select_content(node, element, offset, count) {
    console.log("Selecting " + node.filename + ":" + node.path);

    var surface = d3.select("#surface");

    surface.html("");

    ajaxFunction(
        "/api/content/?filename=" + node.filename + "&path=" + node.path + "&offset=" + offset + "&count=" + (count ? count : 22),

        function(ajax_result){
            var columns = ajax_result.columns;
            var rows = ajax_result.data;

            var grid_contents = {
                Head: [columns],
                Body: rows
            };

            var grid_reference = new Grid(
                surface.node(), {
                    srcType: "json", 
                    srcData: grid_contents, 
                    allowGridResize: true, 
                    allowColumnResize: true, 
                    allowClientSideSorting: true, 
                    allowSelections: true, 
                    allowMultipleSelections: false, 
                    showSelectionColumn: false, 
                    fixedCols: 0,
//                     onRowSelect: handle_selection,
                }
            );
        },

        function(ajax_exception){
        },

        "GET"
    );
}

