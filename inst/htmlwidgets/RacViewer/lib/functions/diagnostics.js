

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
                viewer.onRandomizeMap();
            },
            disabled : false
        });
        relax_btn.classList.add("shiny-element");

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



