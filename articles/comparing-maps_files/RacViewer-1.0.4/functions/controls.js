
Racmacs.ControlPanel = class ControlPanel {

    constructor(viewer){

        this.viewer = viewer;
        viewer.controlpanel = this;
        var controlpanel = this;

        this.visible   = false;
        this.fullwidth = 300;

        // Add button to show and hide controls
        viewer.addButton({
            name  : "toggleControlPanel",
            title : "Toggle the control panel",
            icon  : Racmacs.icons.controlPanel(),
            fn    : function(){
                controlpanel.toggleVisibility();
            }
        });

        // Add holder div
        this.div = document.createElement( 'div' );
        this.div.classList.add("control-panel");
        this.div.style.display = "none";
        this.viewer.wrapper.appendChild( this.div );

        // Create title div
        viewer.viewerTitle = new Racmacs.ViewerTitle(viewer);
        viewer.viewerTitle.div.classList.add("table-name");
        this.div.appendChild(viewer.viewerTitle.div);

        // Create tabset
        this.tabset = new Racmacs.TabSet();
        this.div.appendChild(this.tabset.div);

        // Add load tab
        var loadpanel = new Racmacs.LoadPanel(this.viewer);
        var loadtab = this.tabset.addTab({
            id : "load",
            name: "Load",
            content: loadpanel.div
        });
        loadtab.tab.classList.add("shiny-element");

        // Add save tab
        var savepanel = new Racmacs.SavePanel(this.viewer);
        var savetab = this.tabset.addTab({
            id : "save",
            name: "Save",
            content: savepanel.div
        });
        savetab.tab.classList.add("shiny-element");

        // Add Table
        // var hitablepanel = new Racmacs.HItablePanel(this.viewer);
        // this.tabset.addTab({
        //     id : "hitable",
        //     name: "Table",
        //     content: hitablepanel.div,
        //     onshow: function(){ viewer.showTable() },
        //     onhide: function(){ viewer.hideTable() }
        // });

        // Add Projection list
        var projectionsPanel = new Racmacs.ProjectionsPanel(this.viewer);
        this.tabset.addTab({
            id : "projections",
            name: "Optimizations",
            content: projectionsPanel.div
        });

        // Create name browsers
        this.browsers = {};
        this.browsers.antigens = new Racmacs.NameBrowser(viewer, "antigens");
        this.browsers.sera     = new Racmacs.NameBrowser(viewer, "sera");
        var browserdiv = document.createElement("div");
        browserdiv.classList.add("browser-div");

        browserdiv.appendChild(this.browsers.antigens.div);
        browserdiv.appendChild(this.browsers.sera.div);
        this.tabset.addTab({
            id : "browser",
            name: "Browser",
            content: browserdiv
        });

        // Create color by buttons
        var colorpanel = new Racmacs.ColorPanel(this.viewer);
        this.tabset.addTab({
            id : "colorpanel",
            name: "Coloring",
            content: colorpanel.div
        });

        // Point style panel
        var pointstylepanel = document.createElement("div");
        pointstylepanel.classList.add("load-tab");
        var loadpointstyle = new Racmacs.utils.Button({
            label: "Load point styles",
            fn: function(){ viewer.onLoadPointStyles() }
        });
        loadpointstyle.div.classList.add("shiny-element");
        pointstylepanel.appendChild(loadpointstyle.div);

        // this.tabset.addTab({
        //     id : "pointstylepanel",
        //     name: "Point styles",
        //     content: pointstylepanel
        // });

        // Add Filter
        var filter = new Racmacs.Filter(this.viewer);
        this.tabset.addTab({
            id : "filter",
            name: "Filter",
            content: filter.div
        });

        // Add Diagnostics
        var diagnosticsPanel = new Racmacs.DiagnosticsPanel(this.viewer);
        this.tabset.addTab({
            id : "diagnostics",
            name: "Diagnostics",
            content: diagnosticsPanel.div
        });

        // By default hide the shiny elements
        this.hideShinyElements();

    }

    // Function to hide the panel
    hide(){
        this.visible = false;
        this.setWidth(0);
        this.div.style.display = "none";
    }

    // Function to show the panel
    show(){
        this.visible = true;
        this.setWidth(this.fullwidth);
        this.div.style.display = null;
    }

    // Function to toggle visibility
    toggleVisibility(){

        if(this.visible){
            this.hide();
        } else {
            this.show();
        }

    }

    setWidth(width){
        this.viewer.viewport.holder.style.right = width+"px";
        this.div.style.width  = width+"px";
        this.width = width;
        this.viewer.viewport.onwindowresize(null);
    }

    disableContentLoadedTabs(){
        this.tabset.disableTab("save");
        this.tabset.disableTab("projections");
    }

    enableContentLoadedTabs(){
        this.tabset.enableTab("save");
        this.tabset.enableTab("projections");
    }

    disableProjectionTabs(){
        this.tabset.disableTab("browser");
        this.tabset.disableTab("colorpanel");
        this.tabset.disableTab("filter");
        this.tabset.disableTab("diagnostics");
        this.tabset.disableTab("triangulationblobs");
        this.tabset.disableTab("procrustes");
        this.tabset.disableTab("pointstylepanel");
    }

    enableProjectionTabs(){
        this.tabset.enableTab("browser");
        this.tabset.enableTab("colorpanel");
        this.tabset.enableTab("filter");
        this.tabset.enableTab("diagnostics");
        this.tabset.enableTab("triangulationblobs");
        this.tabset.enableTab("procrustes");
        this.tabset.enableTab("pointstylepanel");
    }

    hideShinyElements(){
        var shiny_elements = this.div.querySelectorAll('.shiny-element');
        for(var i=0; i<shiny_elements.length; i++){
            shiny_elements[i].style.display = "none";
        }
        this.viewer.btns["reflectMap"].style.display = "none";
    }

    showShinyElements(){
        var shiny_elements = this.div.querySelectorAll('.shiny-element');
        for(var i=0; i<shiny_elements.length; i++){
            shiny_elements[i].style.display = null;
        }
        this.viewer.btns["reflectMap"].style.display = null;
    }

}


Racmacs.ColorPanel = class ColorPanel {

    constructor(viewer){

        // Setup
        this.viewer = viewer;
        this.viewer.colorbtns = {};
        this.viewer.colorpanel = this;

        // Create color by options
        this.div = document.createElement( 'div' );
        this.div.id = "color-by-div";

        // Add buttons
        this.addButton(
            "Default",
            function(){
                viewer.colorPointsByDefault();
            },
            true
        );

        this.addButton(
            "Stress",
            function(){
                viewer.colorPointsByStress();
            },
            false
        );

        this.groupbtn = this.addButton(
            "Group",
            function(){
                viewer.colorPointsByGroup();
            },
            false
        );

        this.seqbtn = this.addButton(
            "Sequence",
            e => {
                this.seqinput.focus();
                viewer.colorPointsBySequence(
                    Number(this.seqinput.value)
                );
                this.seqinput.style.display = "";
            },
            false
        );

        this.seqinput = document.createElement("input");
        this.seqinput.setAttribute("placeholder", "position");
        this.seqinput.oninput = e => {
            viewer.colorPointsBySequence(
                Number(this.seqinput.value)
            );
        };
        this.seqinput.style.display = "none";
        this.div.appendChild(this.seqinput);

    }

    addButton(text, fn, checked){

        var div   = document.createElement("div");
        var label = document.createElement("label");
        var input = document.createElement("input");
        var span  = document.createElement("span");

        input.type = "radio";
        input.name = "colorBy";
        input.checked = checked;
        input.onchange = fn;

        label.classList.add("radio-container");
        span.classList.add("radio-checkmark");
        span.classList.add("checkmark");

        label.innerHTML = text;
        label.appendChild(input);
        label.appendChild(span);

        div.appendChild(label);
        div.style.height = "24px";
        this.div.appendChild(div);
        return({
            div : div,
            input : input
        });

    }

    showColorBySequence(){
        this.seqbtn.div.style.display = "";
    }
    hideColorBySequence(){
        this.seqbtn.div.style.display = "none";
    }

    showColorByGroup(){
        this.groupbtn.div.style.display = "";
    }
    hideColorByGroup(){
        this.groupbtn.div.style.display = "none";
    }

}

// EVENTS
R3JS.Viewer.prototype.eventListeners.push({
    name : "point-coloring-changed",
    fn : function(e){
        if(e.detail.viewer.colorpanel.seqbtn.checked){
            e.detail.viewer.colorpanel.seqinput.style.display = "";
            e.detail.viewer.colorpanel.seqinput.focus();
        } else {
            //e.detail.viewer.colorpanel.seqinput.style.display = "none";
        }
    }
});


Racmacs.TabSet = class TabSet {

    constructor(){

        this.div        = document.createElement("div");
        this.div.classList.add("tabset");

        this.tabdiv     = document.createElement("div");
        this.tabdiv.classList.add("tabset-holder");
        this.tabdiv.classList.add("not-selectable");
        this.tabdiv.left = 0;
        this.div.appendChild(this.tabdiv);

        this.tabdiv.addEventListener("wheel", function(event){

            event.preventDefault();
            var overflow = this.scrollWidth - this.offsetWidth;

            if(this.left - event.deltaX > 0){
                this.left = 0;
            } else if(this.left - event.deltaX < -overflow) {
                this.left = -overflow;
            } else {
                this.left -= event.deltaX;
            }

            this.style.left = this.left+"px";

        });

        this.contentdiv = document.createElement("div");
        this.contentdiv.classList.add("tabset-content");
        this.div.appendChild(this.contentdiv);

        this.tabs = [];

    }

    addTab(args){

        // Add tab
        var tab = {
            id : args.id
        };

        // Add content
        tab.content = document.createElement("div");
        tab.content.appendChild(args.content);
        tab.content.classList.add("tabset-content-tab");
        tab.content.style.display = "none";
        this.contentdiv.appendChild(tab.content);

        tab.tab = document.createElement("div");
        tab.tab.classList.add("tab");
        tab.tab.innerHTML = args.name;
        this.tabdiv.appendChild(tab.tab);

        // Add event listener
        var tabpanel = this;
        tab.tab.addEventListener("mouseup", function(){
            if(!this.disabled){
                tabpanel.showTab(args.id);
            }
        });

        // Record focus and blur event listeners
        tab.onshow = args.onshow;
        tab.onhide = args.onhide;

        // Add record
        this.tabs.push(tab);

        // Activate the tab if the first
        if(this.tabs.length == 1){
            this.showTab(args.id);
        }

        return(tab);

    }

    showTab(id){

        for(var i=0; i<this.tabs.length; i++){
            if(this.tabs[i].id === id){
                this.tabs[i].content.style.display = null;
                this.tabs[i].tab.classList.add("active");
                if(this.tabs[i].onshow){ this.tabs[i].onshow() }
            } else {
                if(this.tabs[i].content.style.display !== "none"){
                    if(this.tabs[i].onhide){ this.tabs[i].onhide() }
                }
                this.tabs[i].content.style.display = "none";
                this.tabs[i].tab.classList.remove("active");
            }
        }

    }

    disableTab(id){
        for(var i=0; i<this.tabs.length; i++){
            if(this.tabs[i].id === id){
                this.tabs[i].tab.disabled = true;
                this.tabs[i].tab.classList.add("disabled");
            }
        }
    }

    enableTab(id){
        for(var i=0; i<this.tabs.length; i++){
            if(this.tabs[i].id === id){
                this.tabs[i].tab.disabled = false;
                this.tabs[i].tab.classList.remove("disabled");
            }
        }
    }

}


Racmacs.TableList = class TableList {

    constructor(args){

        this.rows = [];
        this.selectable = args.selectable;

        // Create div
        this.div = document.createElement("div");
        this.div.classList.add("not-selectable");
        this.div.classList.add("table-list");

        // Add the title
        if(args.title){

            var titlediv = document.createElement("div");
            titlediv.classList.add("table-list-title");

            // Add any checkboxes
            if(args.checkbox_check_fn){
                this.checkbox = new Racmacs.utils.Checkbox({
                    check_fn   : args.checkbox_check_fn,
                    uncheck_fn : args.checkbox_uncheck_fn,
                });
                this.checkbox.div.style.height = "12px";
                this.checkbox.div.style.marginRight = "-6px";
                titlediv.appendChild(this.checkbox.div);
            }

            // Add the title
            var title = document.createElement("span");
            title.innerHTML = args.title;
            titlediv.appendChild(title);

            this.div.appendChild(titlediv);

        }

        // Add the holder div
        this.tableHolder = document.createElement( 'div' );
        this.tableHolder.style.position = "relative";
        this.tableHolder.classList.add("tableHolder");
        this.div.appendChild(this.tableHolder);

        // Add the table
        this.table = document.createElement("table");
        this.table.classList.add("innerTable");
        this.div.table = this.table;
        this.tableHolder.appendChild(this.table);

        // Add headers
        this.headerrow = document.createElement("tr");
        this.headerrow.classList.add("innerTableHeader");
        this.table.appendChild(this.headerrow);

        for(var i=0; i<args.headers.length; i++){
            var header = document.createElement("td");
            this.headerrow.appendChild(header);
            header.classList.add("tableCol");
            header.innerHTML = args.headers[i];
        }

        // Add placeholder
        this.placeholder = document.createElement("div");
        this.placeholder.style.position = "absolute";
        this.placeholder.style.left   = 0;
        this.placeholder.style.right  = 0;
        this.placeholder.style.top    = 0;
        this.placeholder.style.bottom = 0;
        this.placeholder.style.backgroundColor = "#222222";
        this.placeholder.style.padding = "4px";
        this.placeholder.style.color = "#666666";
        this.placeholder.style.display = "none";
        this.placeholder.innerHTML = "Not tested";
        this.tableHolder.appendChild(this.placeholder);

    }

    addRow(args){

        // Hide placeholder
        this.hidePlaceholder();

        // Add row
        var row = document.createElement("tr");
        row.classList.add("tableRow");
        this.table.appendChild(row);
        row.num = this.rows.length;

        // Add cells
        for(var i=0; i<args.content.length; i++){
            var cell = document.createElement("td");
            row.appendChild(cell);
            cell.classList.add("tableCol");
            cell.innerHTML = args.content[i];
        }

        // Set event listener
        var tablelist = this;
        row.mouseup = args.fn;
        row.hover = args.hoverfn;
        row.dehover = args.dehoverfn;
        if(this.selectable !== false){
            row.addEventListener("mouseup", function(){
                tablelist.selectRow(this.num);
                this.mouseup();
            });
        }

        if(args.hoverfn){
            row.addEventListener("mouseenter", function(){
                this.hover();
            });
        }
        if(args.dehoverfn){
            row.addEventListener("mouseleave", function(){
                this.dehover();
            });
        }

        // Return the row
        this.rows.push(row);
        return(row);

    }

    clear(){

        if(this.checkbox){
            this.checkbox.disable();
        }
        for(var i=0; i<this.rows.length; i++){
            this.table.removeChild(this.rows[i]);
        }
        this.rows = [];

    }

    selectRow(num, callback = true){
        if(this.selectedRow){
            this.selectedRow.classList.remove("selected");
        }
        this.selectedRow = this.rows[num];
        this.rows[num].classList.add("selected");
        if(this.cancelBtn){
            this.cancelBtn.classList.remove("btn-icon-disabled");
        }
        if(callback){
            this.rows[num].mouseup();
        }
    }

    deselectAll(){
        if(this.selectedRow){
            this.selectedRow.classList.remove("selected");
        }
        this.selectedRow = null;
        if(this.cancelBtn){
            this.cancelBtn.classList.add("btn-icon-disabled");
        }
    }

    checkboxCheck(){
        this.checkbox.check();
    }

    checkboxUncheck(){
        this.checkbox.uncheck();
    }

    showPlaceholder(){
        if(this.placeholder){
            this.placeholder.style.display = "block";
        }
    }

    hidePlaceholder(){
        if(this.placeholder){
            this.placeholder.style.display = "none";
        }
    }

    addDiv(classname){
        var div = document.createElement("div");
        this.div.appendChild(div);
        if(classname){
            div.classList.add(classname);
        }
        return(div);
    }

}

Racmacs.Viewer.prototype.setTitle = function(title){

    if(this.viewerTitle){
        this.viewerTitle.setTitle(title);
    }

}

Racmacs.ViewerTitle = class {

    constructor(viewer){

        // Link viewer
        this.viewer = viewer;

        // Add div
        this.div = document.createElement("div");

    }

    setTitle(title){

        this.div.innerHTML = title;

    }

}

