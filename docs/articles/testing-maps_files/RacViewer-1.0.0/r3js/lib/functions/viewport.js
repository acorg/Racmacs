
R3JS.Viewport = class Viewport{

    constructor(viewer){

        // Set mouse defaults
        this.mouse       = {x:null, y:null};
        this.mouse.down  = false;
        this.mouse.over  = false;
        this.mouse.moved = false;
        this.touch       = {num:0};
        this.onresize    = [];
        this.keydown     = null;

        // Bind the viewport to the viewer
        viewer.viewport = this;
        this.viewer = viewer;

        // Create the overall div parent to fill the container div
        this.wrapper = document.createElement( 'div' );
        this.wrapper.classList.add("r3jsviewer");
        viewer.wrapper = this.wrapper;

        // Create holder
        this.holder = document.createElement( 'div' );
        this.holder.id = "viewport";

        // Create div
        this.div = document.createElement( 'div' );
        this.holder.appendChild(this.div);
        this.div.style.position = "absolute";
        this.div.style.top = 0;
        this.div.style.bottom = 0;
        this.div.style.left = 0;
        this.div.style.right = 0;

        // Clear container and style it
        viewer.container.innerHTML = null;
        viewer.container.appendChild(this.wrapper);
        this.wrapper.appendChild(this.holder);

        // Set width and height
        this.width  = this.div.offsetWidth;
        this.height = this.div.offsetHeight;

        var viewport = this;

        // Add buttons
        if(this.addButtons) this.addButtons();

        // Create canvas for renderer
        this.canvas = document.createElement("div");
        this.canvas.viewport = this;
        this.div.appendChild(this.canvas);

        // Bind events
        this.canvas.addEventListener("mousemove", function(event){ this.viewport.onmousemove(event)   });
        this.canvas.addEventListener("mousedown", function(event){ this.viewport.onmousedown(event)   });
        this.canvas.addEventListener("mouseup",   function(event){ this.viewport.onmouseup(event)     });
        this.canvas.addEventListener("contextmenu",   function(event){ this.viewport.onmouseup(event)     });
        this.canvas.addEventListener("wheel",     function(event){ this.viewport.onmousescroll(event) });
        this.canvas.addEventListener("mouseover", function(event){ this.viewport.onmouseover(event)   });
        this.canvas.addEventListener("mouseout",  function(event){ this.viewport.onmouseout(event)    });

        // Create transformation info div
        this.transform_info = new R3JS.Info("transform-info-div");
        this.div.appendChild( this.transform_info.div );
        
        // Create rotation and translation info
        for (const transform of ["rotation", "translation"]){

            this.transform_info[transform] = { div: document.createElement("div") };
            this.transform_info[transform].div.id = transform+"-info-div";
            this.transform_info.div.appendChild(this.transform_info[transform].div);

            var oninputfn = function(){
                var rotation = [
                    Number(viewer.viewport.transform_info[transform].x.value),
                    Number(viewer.viewport.transform_info[transform].y.value),
                    Number(viewer.viewport.transform_info[transform].z.value)
                ];
                if(transform == "rotation"){
                    viewer.scene.setRotation(rotation);
                }
                if(transform == "translation"){
                    viewer.scene.setTranslation(rotation);
                }
                viewer.render();
            }

            for (const axis of ["x", "y", "z"]){
              var input = document.createElement("input");
              input.classList.add("transform-input");
              input.classList.add("axis-"+transform);
              input.classList.add("axis-"+transform+"-"+axis);
              this.transform_info[transform][axis] = input;
              this.transform_info[transform].div.appendChild(input);
              input.addEventListener("change", oninputfn);
            }

        }

        // Create zoom info
        this.transform_info.zoom = { div: document.createElement("div") };
        this.transform_info.zoom.div.id = "zoom-info-div";
        this.transform_info.div.appendChild(this.transform_info.zoom.div);
        
        var input = document.createElement("input");
        input.classList.add("transform-input");
        this.transform_info.zoom.input = input;
        this.transform_info.zoom.div.appendChild(input);
        input.addEventListener("change", function(){
            viewer.camera.setZoom(Number(this.value));
            viewer.render();
        });

        // Create selection info div
        this.hover_info = new R3JS.Info("hover-info-div");
        this.div.appendChild( this.hover_info.div );

        // Add placeholder
        this.placeholder = document.createElement("div");
        this.placeholder.classList.add("viewport-placeholder");
        this.div.appendChild(this.placeholder);

        // Add event listeners
        viewer.addEventListener("zoom", e => {
            this.transform_info.zoom.input.value = e.detail.end_zoom.toFixed(4);
        });

        viewer.addEventListener("rotate", e => {
            var rotation = viewer.scene.getRotation();
            this.transform_info.rotation.x.value = rotation[0].toFixed(4);
            this.transform_info.rotation.y.value = rotation[1].toFixed(4);
            this.transform_info.rotation.z.value = rotation[2].toFixed(4);
        });

        viewer.addEventListener("translate", e => {
            var translation = viewer.scene.getTranslation();
            this.transform_info.translation.x.value = translation[0].toFixed(4);
            this.transform_info.translation.y.value = translation[1].toFixed(4);
            this.transform_info.translation.z.value = translation[2].toFixed(4);
        });


    }


    // Get width and height
    getWidth(){
        return(this.div.offsetWidth);
    }

    getHeight(){
        return(this.div.offsetHeight);
    }

    getAspect(){
        return(this.getHeight() / this.getWidth());
    }

    setPlaceholder(el, color){
        this.placeholder.innerHTML = "";
        this.placeholder.appendChild(el);
        if(color !== undefined){
            this.placeholder.style.backgroundColor = color;
        }
    }

    hidePlaceholder(){
        this.canvas.style.display = null;
        this.placeholder.style.display = "none";
    }

    showPlaceholder(){
        this.canvas.style.display = "none";
        this.placeholder.style.display = null;
    }

}



R3JS.Info = class Info{

    constructor(id){

        this.div = document.createElement("div");
        this.div.id = id;
        this.hide();

    }

    add(element){

        this.show();
        this.div.appendChild(element);

    }

    remove(element){

        if(element !== null && element !== undefined){
            this.div.removeChild(element);
        }
        if(this.div.children.length === 0){
            this.hide();
        }

    }

    show(){ 
        this.div.style.display = "block";
        this.shown = true;
    }
    hide(){ 
        this.div.style.display = "none"
        this.shown = false;
    }
    toggle(){
        if(this.shown){
            this.hide();
        } else {
            this.show();
        }
    }

}

R3JS.Viewer.prototype.addHoverInfo = function(div){
    this.viewport.hover_info.add(div);
}

R3JS.Viewer.prototype.removeHoverInfo = function(div){
    this.viewport.hover_info.remove(div);
}


