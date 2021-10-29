
R3JS.Viewer.prototype.eventListeners.push({
    name : "point-selected",
    fn : function(e){
        let point  = e.detail.point;
        let viewer = point.viewer;
        if (viewer.selected_pts.length == 1 && point.type == "ag") {
            
            viewer.aginfopanel.style.display = "block";
            viewer.aginfopanel.agreactivityslot.value = viewer.data.agReactivityAdjustment(point.typeIndex);

        } else {

            viewer.aginfopanel.style.display = "none";

        }
    }
});

R3JS.Viewer.prototype.eventListeners.push({
    name : "points-deselected",
    fn : function(e){
        let viewer = e.detail.viewer;
        viewer.aginfopanel.style.display = "none";
    }
});

Racmacs.DiagnosticsPanel = class DiagnosticsPanel {

    constructor(viewer){

        // Create holder div
        this.div = document.createElement("div");
        this.div.classList.add("diagnostics-tab");

        var btnpanel = new Racmacs.ButtonPanel(viewer);
        this.div.appendChild(btnpanel.div);

        // Create buttons div
        this.buttons = document.createElement("div");
        this.buttons.classList.add("buttons-div");
        this.buttons.classList.add("shiny-element");
        this.div.appendChild(this.buttons);

        // Add the find hemisphering button
        var findHemispheringBtn = new Racmacs.utils.Button({
            label : "Check for hemisphering",
            fn : function(){ viewer.onCheckHemisphering() }
        });
        this.buttons.appendChild(findHemispheringBtn.div);

        // Add the move trapped points button
        var moveTrappedPointsBtn = new Racmacs.utils.Button({
            label : "Move trapped points",
            fn : function(){ viewer.onMoveTrappedPoints() }
        });
        this.buttons.appendChild(moveTrappedPointsBtn.div);


        // Add the optimizer panel control
        var optimizer_control_panel = document.createElement("div");
        this.div.appendChild(optimizer_control_panel);

        var fix_ags_panel = document.createElement("div");
        optimizer_control_panel.appendChild(fix_ags_panel);
        var fix_ags_checkbox = document.createElement("input");
        fix_ags_checkbox.setAttribute("type", "checkbox");
        fix_ags_checkbox.addEventListener("change", e => {
            if (e.target.checked) viewer.dispatchEvent("optimizer-ags-fixed", { viewer : viewer });
            else                  viewer.dispatchEvent("optimizer-ags-unfixed", { viewer : viewer });
        });
        fix_ags_panel.appendChild(fix_ags_checkbox);
        var fix_ags_label = document.createElement("span");
        fix_ags_label.style.marginLeft = "4px";
        fix_ags_label.style.fontSize = "90%";
        fix_ags_label.innerHTML = "Fix antigens";
        fix_ags_panel.appendChild(fix_ags_label);

        var fix_srs_panel = document.createElement("div");
        optimizer_control_panel.appendChild(fix_srs_panel);
        var fix_srs_checkbox = document.createElement("input");
        fix_srs_checkbox.setAttribute("type", "checkbox");
        fix_srs_panel.appendChild(fix_srs_checkbox);
        fix_srs_checkbox.addEventListener("change", e => {
            if (e.target.checked) viewer.dispatchEvent("optimizer-srs-fixed", { viewer : viewer });
            else                  viewer.dispatchEvent("optimizer-srs-unfixed", { viewer : viewer });
        });
        var fix_srs_label = document.createElement("span");
        fix_srs_label.style.marginLeft = "4px";
        fix_srs_label.style.fontSize = "90%";
        fix_srs_label.innerHTML = "Fix sera";
        fix_srs_panel.appendChild(fix_srs_label);


        // Add the antigen info panel
        var aginfopanel = document.createElement("div");
        aginfopanel.style.border = "1px solid rgb(16, 87, 116)";
        aginfopanel.style.borderRadius = "4px";
        aginfopanel.style.backgroundColor = "#000000";
        aginfopanel.style.padding = "8px";
        aginfopanel.style.fontSize = "85%";
        aginfopanel.style.display = "none";
        this.div.appendChild(aginfopanel);
        viewer.aginfopanel = aginfopanel;

        // Add the name panel
        // var agnameslot = document.createElement("input");
        // agnameslot.value = "antigen 1";
        // agnameslot.contentEditable = true;
        // agnameslot.style.width = "100%";
        // agnameslot.style.backgroundColor = "transparent";
        // agnameslot.style.outline = "none";
        // aginfopanel.appendChild(agnameslot);

        // Add the ag reactivity panel
        var agreactivity = document.createElement("div");
        agreactivity.style.textAlign = "right";
        aginfopanel.appendChild(agreactivity);
        agreactivity.classList.add("not-selectable");

        var agreactivitylabel = document.createElement("div");
        agreactivitylabel.innerHTML = "Antigen reactivity adjustment:";
        agreactivitylabel.style.display = "inline-block";
        agreactivitylabel.style.marginRight = "10px";
        agreactivity.appendChild(agreactivitylabel);
        
        var agreactivityplus = document.createElement("div");
        var agreactivityminus = document.createElement("div");
        var agreactivityslot = document.createElement("input");

        var agreactivityplusminus = document.createElement("div");
        agreactivityplusminus.style.display = "inline-block";
        agreactivityplusminus.style.marginRight = "4px";
        agreactivity.appendChild(agreactivityplusminus);

        agreactivityplus.innerHTML = "+";
        agreactivityplus.style.display = "inline-block";
        agreactivityplus.style.padding = "2px 4px";
        agreactivityplus.style.fontWeight = "bolder";
        agreactivityplus.style.cursor = "pointer";
        agreactivityplus.style.border = "solid 1px green";
        agreactivityplus.style.width = "8px";
        agreactivityplus.style.textAlign = "center";
        agreactivityplus.style.borderRadius = "2px";
        agreactivityplus.style.marginRight = "4px";
        agreactivityplusminus.appendChild(agreactivityplus);

        agreactivityplus.addEventListener("mouseup", e => {
            agreactivityslot.value = Number(agreactivityslot.value) + 1;
            var event = document.createEvent('HTMLEvents');
            event.initEvent('change', false, true); // onchange event
            agreactivityslot.dispatchEvent(event);
        });

        agreactivityminus.innerHTML = "-";
        agreactivityminus.style.display = "inline-block";
        agreactivityminus.style.padding = "2px 4px";
        agreactivityminus.style.fontWeight = "bolder";
        agreactivityminus.style.cursor = "pointer";
        agreactivityminus.style.border = "solid 1px red";
        agreactivityminus.style.width = "8px";
        agreactivityminus.style.textAlign = "center";
        agreactivityminus.style.borderRadius = "2px";
        agreactivityplusminus.appendChild(agreactivityminus);

        agreactivityminus.addEventListener("mouseup", e => {
            agreactivityslot.value = Number(agreactivityslot.value) - 1;
            var event = document.createEvent('HTMLEvents');
            event.initEvent('change', false, true); // onchange event
            agreactivityslot.dispatchEvent(event);
        });

        agreactivityslot.style.width = "20px";
        agreactivityslot.style.display = "inline-block";
        agreactivityslot.style.padding = "4px";
        agreactivityslot.style.borderRadius = "4px";
        // agreactivityslot.style.backgroundColor = "transparent";
        agreactivityslot.style.outline = "none";
        agreactivityslot.addEventListener("change", e => {
            
            // Set the antigen reactivity in the data
            viewer.data.setAgReactivityAdjustment(
                viewer.selected_pts[0].typeIndex,
                Number(agreactivityslot.value)
            );

            // Dispatch an event
            viewer.dispatchEvent("ag-reactivity-changed", { 
                point : viewer.selected_pts[0],
                reactivity : Number(agreactivityslot.value)
            });

        });
        agreactivity.appendChild(agreactivityslot);
        aginfopanel.agreactivityslot = agreactivityslot;

    }


}


// Panel for buttons
Racmacs.ButtonPanel = class ButtonPanel {

    constructor(viewer){

        // Setup
        this.viewer = viewer;
        this.viewer.controlbtns = {};
        this.div = document.createElement("div");
        this.div.classList.add("button-panel");

        // Add relax map button
        var relax_btn = this.addButton({
            name  : "relaxMap",
            title : "Relax map points",
            icon  : Racmacs.icons.relax(),
            fn    : function(e){
                if (e.shiftKey) {
                    viewer.onRelaxMapOneStep();
                    viewer.relaxMap(e.altKey, 1);
                } else {
                    viewer.onRelaxMap();
                    viewer.toggleRelaxMap(e.altKey);
                }
            },
            disabled : false
        });

        // Add a custom event listener for the meta key
        relax_btn.addEventListener("mousedown", e => {
            if (e.metaKey) {
                viewer.relaxMap(e.altKey);
            }
        });
        relax_btn.addEventListener("mouseup", e => {
            if (e.metaKey) {
                viewer.endOptimizer();
            }
        });
        // relax_btn.classList.add("shiny-element");

        // Add randomise button
        var relax_btn = this.addButton({
            name  : "randomizeMap",
            title : "Randomize map points",
            icon  : Racmacs.icons.randomize(),
            fn    : function(e){
                viewer.randomizeCoords();
            },
            disabled : false
        });
        // relax_btn.classList.add("shiny-element");

        // Add connection lines button
        this.addButton({
            name  : "toggleConnectionLines",
            title : "Toggle connection lines",
            icon  : Racmacs.icons.connectionLines(),
            fn    : function(e){
                viewer.toggleConnectionLines();
            }
        });

        // Add error lines button
        this.addButton({
            name  : "toggleErrorLines",
            title : "Toggle error lines",
            icon  : Racmacs.icons.errorLines(),
            fn    : function(e){
                viewer.toggleErrorLines();
            }
        });

        // Add drag points button
        this.addButton({
            name  : "toggleDragMode",
            title : "Toggle move points mode",
            icon  : Racmacs.icons.movePoints(),
            fn    : function(e){
                viewer.toggleDragMode();
            },
            disabled : true
        });

    }

    addButton(args){

        // Create and style button
        var btn = document.createElement( 'div' );
        btn.classList.add("btn-icon");
        btn.classList.add('not-selectable');
        btn.style.fontSize = "28px";
        btn.title     = args.title;
        btn.innerHTML = args.icon;

        // Add button record
        this.div.appendChild(btn);
        this.viewer.btns[args.name] = btn;

        // Add event listeners
        btn.addEventListener('mousedown', function(e){
            e.stopPropagation();
        });
        btn.addEventListener('mouseup', function(e){
            if(!btn.disabled){
                args.fn(e);
            }
            e.stopPropagation();
        });

        // Add methods to update the button
        btn.updateIcon = function(icon){
            this.innerHTML = icon;
        }

        btn.highlight = function(){
            btn.classList.add("btn-icon-selected");
            this.selected = true;
        }

        btn.dehighlight = function(){
            btn.classList.remove("btn-icon-selected");
            this.selected = false;
        }

        btn.disable = function(){
            btn.classList.add("btn-icon-disabled");
            this.disabled = true;
        }

        btn.enable = function(){
            btn.classList.remove("btn-icon-disabled");
            this.disabled = false;
        }
        
        // Disable if required
        if(args.disabled){
            btn.disable()
        }

        return(btn);

    }

}


Racmacs.Viewer.prototype.clearDiagnostics = function(){

    if(this.procrustesTable){

        this.procrustesTable.clear();

    }

    if(this.blobTable){

        this.blobTable.clear();

    }

    if(this.hemispheringTable){

        this.hemispheringTable.clear();

    }

}



