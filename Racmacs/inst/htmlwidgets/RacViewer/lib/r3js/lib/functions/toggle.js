
function addToggles(viewport){

	var toggles = viewport.scene.toggles;

    // Create toggles
    var toggle_holder = document.createElement("div");
    toggle_holder.id = "toggle-div";
    viewport.appendChild(toggle_holder);
    
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
                this.objects[i].visible = this.on;
            }

            // Style button
            if(this.on){
                this.style.background = "#eeeeee";
                this.style.color    = "#444444";
            } else {
                this.style.background = "#f6f6f6";
                this.style.color    = "#cccccc";
            }

            viewport.sceneChange = true;
        }
        toggle.toggleBtn = toggleBtn;
        
        // Add the click event listener
        toggle.addEventListener("mouseup", toggleBtn);
        toggle.addEventListener("touchend", toggleBtn);
        toggle.toggleBtn();
        
    }

}

