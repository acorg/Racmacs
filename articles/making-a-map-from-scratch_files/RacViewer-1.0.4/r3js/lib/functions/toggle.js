
R3JS.Viewer.prototype.addToggles = function(){

    var viewer   = this;
    var viewport = this.viewport;
	var toggles  = this.scene.toggles;

    // Create toggles
    var toggle_holder = document.createElement("div");
    toggle_holder.id = "toggle-div";
    viewport.div.appendChild(toggle_holder);
    
    // Style toggle holder
    if (viewer.settings.styles && viewer.settings.styles.togglediv) {
        Object.assign(toggle_holder.style, viewer.settings.styles.togglediv);
    } else {
        toggle_holder.style.top = "32px";
        toggle_holder.style.right = "8px";
    }

    for(var i=0; i<toggles.names.length; i++){

        var toggle = document.createElement("div");
        toggle.innerHTML = toggles.names[i];
        toggle.classList.add('not-selectable');
        toggle.classList.add('toggle');
        toggle.objects = toggles.objects[i];
        toggle_holder.appendChild(toggle);


        // Add toggle functions
        toggle.on = false;
        toggleBtn = function(){

            // Toggle button
            this.on = !this.on;

            // Hide/show objects
            for(var i=0; i<this.objects.length; i++){
                if(this.on){
                    this.objects[i].show();
                } else {
                    this.objects[i].hide();
                }
            }

            // Style button
            if(this.on){
                if(viewer.settings.styles 
                    && viewer.settings.styles.toggles
                    && viewer.settings.styles.toggles[this.innerHTML]
                    && viewer.settings.styles.toggles[this.innerHTML].on){

                    Object.assign(this.style, viewer.settings.styles.toggles[this.innerHTML].on);

                } else {

                    this.style.background = "#eeeeee";
                    this.style.color    = "#444444";

                }
            } else {
                if(viewer.settings.styles 
                    && viewer.settings.styles.toggles
                    && viewer.settings.styles.toggles[this.innerHTML]
                    && viewer.settings.styles.toggles[this.innerHTML].off){

                    Object.assign(this.style, viewer.settings.styles.toggles[this.innerHTML].off);

                } else {

                    this.style.background = "#f6f6f6";
                    this.style.color    = "#cccccc";
                    
                }
            }

            // Re render the scene
            viewer.render();

        }
        toggle.toggleBtn = toggleBtn;
        
        // Add the click event listener
        toggle.addEventListener("mouseup", toggleBtn);
        toggle.addEventListener("touchend", toggleBtn);
        toggle.toggleBtn();
        
    }

}

