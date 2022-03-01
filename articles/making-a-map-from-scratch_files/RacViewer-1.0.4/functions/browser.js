
R3JS.Viewer.prototype.eventListeners.push({
    name : "point-selected",
    fn : function(e){
        let point  = e.detail.point;
        let viewer = point.viewer;
        point.browserRecord.select();
    }
});

R3JS.Viewer.prototype.eventListeners.push({
    name : "point-deselected",
    fn : function(e){
        let point  = e.detail.point;
        let viewer = point.viewer;
        point.browserRecord.deselect();
    }
});

R3JS.Viewer.prototype.eventListeners.push({
    name : "point-included",
    fn : function(e){
        let point  = e.detail.point;
        let viewer = point.viewer;
        point.browserRecord.unfade();
    }
});

R3JS.Viewer.prototype.eventListeners.push({
    name : "point-excluded",
    fn : function(e){
        let point  = e.detail.point;
        let viewer = point.viewer;
        point.browserRecord.fade();
    }
});

// Clear browsers
Racmacs.App.prototype.clearBrowsers = function(){
    for(browser in this.browsers){
        this.browsers[browser].clear();
    }
}

Racmacs.NameBrowser = class NameBrowser {

    // Constructor function
    constructor(viewer, type){

        // Set type and name defaults
        this.type = type;
        if(type == "antigens"){
            this.name = "Antigens";
        } else if(type == "sera"){
            this.name = "Sera";
        } else {
            throw("Point type '"+type+"' not understood");
        }

        // Store name divs
        this.points = [];
        this.lastSelected = null;

        // Link viewer and browser
        this.viewer = viewer;
        viewer.browsers[type] = this;

        // Create div
        this.div = document.createElement( 'div' );
        this.div.classList.add("browser-holder");

        // Add title
        var title = document.createElement( 'div' );
        this.div.appendChild(title);
        title.innerHTML = this.name;
        title.classList.add("browser-title");

        // Add search box
        this.search_box = new Racmacs.BrowserSearchBox(this);
        this.div.appendChild(this.search_box.input);

        // Add name list
        this.name_list_holder = document.createElement( 'div' );
        this.name_list_holder.classList.add("name-list-holder");
        this.div.appendChild(this.name_list_holder);

        this.name_list = document.createElement( 'div' );
        this.name_list.classList.add("name-list");
        this.name_list_holder.appendChild(this.name_list);

        // Add mouse event listeners to name list
        var noneSelected_deselected_opacity = viewer.styleset.noselections.unhovered.unselected.opacity;
        var plusSelected_deselected_opacity = viewer.styleset.selections.unhovered.unselected.opacity;

        this.name_list.addEventListener("mouseenter", function(){
            viewer.styleset.noselections.unhovered.unselected.opacity = plusSelected_deselected_opacity;
            viewer.updatePointStyles();
        });
        this.name_list.addEventListener("mouseleave", function(){
            viewer.styleset.noselections.unhovered.unselected.opacity = noneSelected_deselected_opacity;
            viewer.updatePointStyles();
        });

    }

    // Function to clear the name browser
    clear(){

        this.points = [];
        while(this.name_list.children.length > 0){
            this.name_list.removeChild(this.name_list.children[0]);
        }

    }

    // Function to populate the name browser
    populate(order = null){

        // Get points
        var points = this.viewer[this.type];

        // Clear it
        this.clear();

        // Set default order
        if(order === null){ order = Array(points.length).fill(0).map( (a,i) => i ) }
        
        // Populate name browser
        for(var i=0; i<order.length; i++){
            
            points[order[i]].browserRecord.nameBrowser = this;
            points[order[i]].browserRecord.browserIndex = i;
            this.name_list.appendChild(points[order[i]].browserRecord.div);
            this.points.push(points[order[i]]);

        }

    }

    // Order name list
    order(sorting){

        // Get points
        var points = this.viewer[this.type];
        var order  = Array(points.length).fill(0).map( (a,i) => i );
        
        // Work out sorting
        if(sorting == "default"){

            var drawing_order = points.map( p => p.drawing_order );
            order.sort(function(a,b){
                return(drawing_order[b] - drawing_order[a]);
            });

        } else if(sorting == "stress"){
            
            var stress = points.map( p => p.calcMeanStress() );
            order.sort(function(a,b){
              return(stress[b] - stress[a]);
            });

        } else if(sorting == "group"){

            var group = points.map( p => p.group );
            order.sort(function(a,b){
              return(group[b] - group[a]);
            });

        } else if(sorting == "year"){
            
            var years = points.map( p => p.year );
            order.sort(function(a,b){
              return(years[a] - years[b]);
            });

        } else if(sorting == "procrustes"){

            var pcdist = [];
            for (var i = 0; i < points.length; i++) {
                var dist = points[i].procrustes.dist;
                if(dist == "NA"){
                    dist = 0;
                }
                pcdist.push(dist);
            }
            order.sort(function(a,b){
              return(pcdist[b] - pcdist[a]);
            });

        } else {

            throw "Sorting not correctly specified";

        }

        // Set the order and repopulate the browser
        this.populate(order);

    }

}



Racmacs.BrowserSearchBox = class BrowserSearchBox {

    constructor(browser){

        this.input = document.createElement( 'input' );
        this.input.type = "text";
        this.input.classList.add("search-box");

        // Add event listeners
        this.input.addEventListener("keyup", function(){

            var search = this.value;
            var points = browser.viewer[browser.type];

            for(var i=0; i<points.length; i++){
                
                var point = points[i];
                if(point.name.toLowerCase().indexOf(search.toLowerCase()) == -1) {
                    point.browserRecord.hide();
                } else {
                    point.browserRecord.show();
                }

            }

        });

    }

}


Racmacs.BrowserRecord = class BrowserRecord {

    constructor(point){

        // Link point
        this.point = point;
        var browserRecord = this;

        // Create the overall name div
        this.div = document.createElement( 'div' );
        this.div.style.cursor = "default";
        this.div.style.width = "100%";

        // Create the color box
        this.col_box = document.createElement( 'div' );
        this.col_box.style.display = "inline-block";
        this.col_box.style.height = "8px";
        this.col_box.style.width = "8px";
        this.col_box.style.boxSizing = "border-box";
        this.col_box.style.marginRight = "6px";
        this.div.appendChild(this.col_box);

        // Create the name box
        this.name_box = document.createElement( 'div' );
        this.name_box.style.display = "inline-block";
        this.div.appendChild(this.name_box);

        // Make red if na_coords
        if(point.coords_na || !point.shown){
            this.name_box.classList.add("na-coords");
        }

        // Update the box
        this.updateColor();
        this.updateName();

        // Add div event listeners
        this.div.addEventListener("mouseenter", function(){
            point.hover();
            browserRecord.hover();
        });
        this.div.addEventListener("mouseleave", function(){
            point.dehover();
            browserRecord.dehover();
        });
        this.div.addEventListener("mousedown", function(e){
            e.preventDefault();
        });
        this.div.addEventListener("mouseup", function(e){
            
            e.preventDefault();

            if (e.altKey) {

                point.toggleIncluded();

            } else {

                if(!e.shiftKey && !e.metaKey){
                    point.viewer.deselectAll();
                }

                var namebrowser = browserRecord.nameBrowser;
                var selected_points = namebrowser.viewer.selected_pts;
                var index = browserRecord.browserIndex;
                
                if(e.shiftKey && selected_points.length > 0){
                    var indexLast = namebrowser.lastSelected;
                    if(indexLast !== null){
                        
                        if(index > indexLast){
                            for(var i=indexLast; i<index; i++){
                                namebrowser.points[i].select();
                            }
                        }

                        if(index < indexLast){
                            for(var i=indexLast; i>index; i--){
                                namebrowser.points[i].select();
                            }
                        }

                    }
                }

                namebrowser.lastSelected = index;
                point.select();

            }

        });

    }

    hide(){
        this.div.style.display = "none";
    }

    show(){
        this.div.style.display = "block";
    }

    hover(){
        this.div.classList.add("hover");
    }

    dehover(){
        this.div.classList.remove("hover");
    }

    select(){
        this.div.classList.add("selected");
    }

    deselect(){
        this.div.classList.remove("selected");
    }

    fade(){
        if(!this.point.coords_na){
            this.name_box.classList.add("na-coords");
        }
    }

    unfade(){
        if(!this.point.coords_na){
            this.name_box.classList.remove("na-coords");
        }
    }

    updateColor(){
        var col = "#" + this.point.getPrimaryColorHex();
        this.col_box.style.backgroundColor = col;
        if(col == "#000000" || col == "black"){
            this.col_box.style.borderStyle = "solid";
            this.col_box.style.borderColor =  "white";
            this.col_box.style.borderWidth =  "1px";
        } else {
            this.col_box.style.borderStyle = "none";
        }
    }

    updateName(){
        this.name_box.innerHTML = this.point.name;
    }

}




